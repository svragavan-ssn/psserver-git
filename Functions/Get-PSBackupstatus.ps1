Function Get-PSBackupStatus {
    <#
        .SYNOPSIS
            Gets backup status of a machine.
        
        .DESCRIPTION
            Gets backup status from Local machine or Remote machine.You can supply date to take information from particular date or range of days.
        
        .PARAMETER ComputerName
            The target machine name to get the information. Defaults to localhost.

        .PARAMETER Fromdate
            Input the date (MM/DD/YYYY) to get the backup infomation of that particular day.This parameter is mandatory.

        .PARAMETER Enddate
            Input the date (MM/DD/YYYY) to get the backup infomation from date to end date range.

        .EXAMPLE
            Get-PSBackupStatus
            
            Gets backup status of local machine.

        .EXAMPLE
            Get-PSBackupStatus -computername SRVTST01 -fromdate 1/09/2018
            
            Gets backup status of machine SRVTST01 for date January 09 2018.

        .EXAMPLE
            Get-PSBackupStatus -computername SRVTST01 -fromdate 1/09/2018 -enddate 1/10/2018
            
            Gets backup status of machine SRVTST01 from January 09 2018 to January 10 2018  

        .EXAMPLE
            Get-PSBackupStatus -computername SRVTST01,SRVTST02
            
            Gets backup status of of machines SRVTST01 and SRVTST02.
    
        .EXAMPLE
            Get-content .\list.txt | Get-PSBackupStatus
            
            Keep multiple machine name in TXT file to get their backup status.
        
        .EXAMPLE
            Import-Csv  .\list.csv | Get-PSBackupStatus
            
            Keep multiple machine name in CSV file to get their backup status.
            
        .NOTES
            Author: Vijayaragavan S (@Ragavanvs)
            Tags: 
            
            Website: 
            Copyright: (C) Vijayaragavan
            License:  
    #>     
    [cmdletbinding()]
    param (    
        [parameter(Mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$computername = $env:COMPUTERNAME,
        [parameter(Mandatory = $false)]
        [DateTime]$Fromdate = (Get-Date).AddDays(-1),
        [parameter(Mandatory = $false)]
        [DateTime]$Enddate
    )
    Begin {
    
    }        
    Process {
        foreach ($Computer in $ComputerName) { 
            if (Test-connection $computer -count 1 -quiet:$true) {
            
                if ($enddate) {
                    $enddate = $enddate.AddHours(24) 
                }
                else {
                    $enddate = $fromdate.AddHours(24) 
                }    

                try {
                    $events = Get-WinEvent -computername $computer -FilterHashtable @{logname = 'Application'; ProviderName = 'AdsmClientService'; StartTime = $fromdate; EndTime = $enddate; ID = 4097, 4099 } -ErrorAction Stop | Sort-Object -Property Timecreated                                    
                }
                catch {                    
                    $ErrorMessage = $_.Exception.Message                                                                   
                }  
                              
                if ($events) {
                    
                    $schedules = @{}
               
                    $backupconfig = Get-PSBackupconfiguration -computername $computer
                    $service = get-service -ComputerName $computer -Name "TSM*" -ErrorAction SilentlyContinue | Select-Object Name, Status
                    $servstatus = ""
                    if ($service) {
                        foreach ($serv in $service) {
                            $servstatus = "TSM Service is running"
                            if ($serv.status -ne "Running") {
                                $servstatus = ""
                                if ($serv.name.startswith("TSM Central Scheduler")) {
                                    $servstatus += "Central Scheduler service is not Running"
                                    $servstatus += ":"
                                }
                                
                                if ($serv.name.startswith("TSM Cluster")) {
                                    $getservice = [regex]::matches($serv.Name, "TSM Cluster\s(\w*)")
                                    $disk = $getservice.groups.value[1]
                                    $servstatus += "Service for $disk is not running"
                                    $servstatus += ":"
                                }                                
                            }                            
                        }
                    }                
                    else {

                        $servstatus = "No TSM Service available"
                    }

                    foreach ($evnt in $events) {  
                        
                        if ($evnt.message.startswith("Execution of")) {
                            
                            $getschedule = [regex]::matches($evnt.message, ".Schedule\s(\w*)|(\-\w*)")
                            if ($getschedule.groups[3]) {
                                $schedulename = $getschedule.groups[1].value
                                $schedulename += $getschedule.groups[3].value                                                            
                            }
                            else {
                                $schedulename = $getschedule.groups[1].value                                                      
                            }
                            
                            $schedules.$schedulename = @{}
                            $schedules.$schedulename.start = $false
                            $schedules.$schedulename.end = $false
                            $schedules.$schedulename.backupstarttime = $evnt.timecreated
                            $schedules.$schedulename.start = $True                            
                            $schedules.$schedulename.schedulename = $schedulename
                            $schedules.$schedulename.ComputerName = $Computer                                                                                                                                                                                       
                        }                                                        
                        if ($evnt.message.endswith("Successfully Completed.")) {                            
                           
                            $getsuccschedule = [regex]::matches($evnt.message, "Schedule\s(\w*)|(\-\w*)")
                            if ($getsuccschedule.groups[3]) {
                                $schedname = $getsuccschedule.groups[1].value    
                                $schedname += $getsuccschedule.groups[3].value                      
                            }
                            else {
                                $schedname = $getsuccschedule.groups.value[1]                                 
                            }
                                                                                                       
                            if ($schedules.$schedname) {  
                               
                                $completedtime = $evnt.timecreated                                                         
                                $status = "Successfully Completed."
                                $schedules.$schedname.end = $True                       
                                $schedules.$schedname.completedtime = $completedtime                                               
                                $schedules.$schedname.Status = $status                                                                                          
                            }                            
                            if ($schedules.$schedname.start -and $schedules.$schedname.end) {
                                $tottime = New-TimeSpan $schedules.$schedname.BackupStarttime $schedules.$schedname.Completedtime                         
                               
                                $info = [ordered]@{ 
                                    ComputerName     = $schedules.$schedname.ComputerName
                                    BackupStarttime  = $schedules.$schedname.BackupStarttime
                                    BackupEndTime    = $schedules.$schedname.Completedtime 
                                    TotalTime        = $tottime
                                    Schedulename     = $schedules.$schedname.Schedulename   
                                    BackupServerName = $backupconfig.BackupServerName
                                    ServiceStatus    = $servstatus                                                      
                                    Status           = $schedules.$schedname.Status      
                                }                        
                                $backupinformation = New-Object PSOBject -Property $info   
                                $backupinformation
                                $schedules.$schedname.start = $false                                                                                                      
                                $schedules.$schedname.end = $false                                                                                                          
                            }                                                          
                        }
                        if ($evnt.message.startswith("Failure Executing Schedule")) {

                            $getfailschedule = [regex]::matches($evnt.message, ".Schedule\s(\w*)")
                            
                            if ($getfailschedule.groups.value[3]) {
                                $schedname = $getfailschedule.groups[1].value
                                $schedname += $getfailschedule.groups[3].value                
                            }

                            else {
                                $schedname = $getfailschedule.groups.value[1]                                 
                            }   

                            if ($schedules.$schedname) {
                                
                                $completedtime = $evnt.timecreated                                                         
                                $geterror = [regex]::matches($evnt.message, ".\,\s(\w*\=\w*)")
                                $errcode = $geterror.groups.value[1] 
                                $status = "Backup Failed Errorcode $errcode."
                                $schedules.$schedname.end = $True  
                                $schedules.$schedname.completedtime = $completedtime                                             
                                $schedules.$schedname.Status = $status                                    
                            } 
                            
                            if ($schedules.$schedname.start -and $schedules.$schedname.end) {
                                $tottime = New-TimeSpan $schedules.$schedname.BackupStarttime $schedules.$schedname.Completedtime                         
                               
                                $info = [ordered]@{ 
                                    ComputerName     = $schedules.$schedname.ComputerName
                                    BackupStarttime  = $schedules.$schedname.BackupStarttime
                                    BackupEndTime    = $schedules.$schedname.Completedtime 
                                    TotalTime        = $tottime
                                    Schedulename     = $schedules.$schedname.Schedulename   
                                    BackupServerName = $backupconfig.BackupServerName   
                                    ServiceStatus    = $servstatus                                                                            
                                    Status           = $schedules.$schedname.Status      
                                }                        
                                $backupinformation = New-Object PSOBject -Property $info   
                                $backupinformation
                                $schedules.$schedname.start = $false                                                                                                      
                                $schedules.$schedname.end = $false                                                                                                          
                            } 
                        }                                                                                                                                                                                                                                                                                                  
                    }       
                }
                else {
                    $info = [ordered]@{ 
                        ComputerName     = $Computer
                        BackupStarttime  = ""
                        BackupEndTime    = "" 
                        TotalTime        = ""
                        Schedulename     = ""    
                        BackupServerName = ""   
                        ServiceStatus    = ""                                                 
                        Status           = "No Backup Events Found"             
                    }                        
                    $backupinformation = New-Object PSOBject -Property $info   
                    $backupinformation
                }                                                                                                                                                                                                                                                                                         
            }
            else {

                $info = [ordered]@{ 
                    ComputerName     = $Computer
                    BackupStarttime  = ""
                    BackupEndTime    = ""                                                      
                    TotalTime        = ""
                    Schedulename     = "" 
                    BackupServerName = ""  
                    ServiceStatus    = ""             
                    Status           = "Computer is not reachable"                      
                }                        
                $backupinformation = New-Object PSOBject -Property $info   
                $backupinformation                 
            }   
        }
    }
    End {
    
    }    
}