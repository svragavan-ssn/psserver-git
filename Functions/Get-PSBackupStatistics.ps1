Function Get-PSBackupStatistics {
    <#
        .SYNOPSIS
            Gets backup statistics of a machine.
        
        .DESCRIPTION
           Gets backup statistics from Local machine or Remote machine.You can supply date to take information from particular date or range of days.
        
        .PARAMETER ComputerName
            The target machine name to get the information. Defaults to localhost.
        
        .EXAMPLE
            Get-PSBackupStatistics
            
            Gets backup statistics of local machine.
        .EXAMPLE
            Get-PSBackupStatistics -computername SRVTST01 -fromdate 1/09/2018
            
            Gets backup statistics of machine SRVTST01 for date January 09 2018.

        .EXAMPLE
            Get-PSBackupStatistics -computername SRVTST01 -fromdate 1/09/2018 -enddate 1/10/2018
            
            Gets backup statistics of machine SRVTST01 from January 09 2018 to January 10 2018  
        .EXAMPLE
            Get-PSBackupStatistics -computername SRVTST01,SRVTST02
            
            Gets backup statistics of machines SRVTST01 and SRVTST02.
    
        .EXAMPLE
            Get-content .\list.txt | Get-PSBackupStatistics
            
            Keep multiple machine name in TXT file to get their backup statistics.
        
        .EXAMPLE
            Import-Csv  .\list.csv | Get-PSBackupStatistics
            
            Keep multiple machine name in CSV file to get their backup statistics.
            
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
        [DateTime]$fromdate = (Get-Date).AddDays(-1),
        [parameter(Mandatory = $false)]
        [DateTime]$enddate 
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
                    $statistics = Get-WinEvent -computername $computer -FilterHashtable @{logname = 'Application'; ProviderName = 'AdsmClientService'; StartTime = $fromdate; EndTime = $enddate; ID = 4102 } | Sort-Object -Property Timecreated 
                   
                    foreach ($startevent in $statistics) {
                        $Date = $startevent.timecreated
                        
                        $eventxml = [xml]$startevent.Toxml()
                        $data = $eventxml.event.eventdata.data
                        $schedulename = $data[1]                        
                        $inspected = [regex]::matches($data[2], ".*\w:\s*([+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?)")
                        $backedup = [regex]::matches($data[3], ".*\w:\s*([+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?)")
                        $failed = [regex]::matches($data[8], ".*\w:\s*([+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?)")
                        $bytestransferred = [regex]::matches($data[10], ".*\w:\s*([+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?)\s*(\w*)")
                        $transfertime = [regex]::matches($data[11], ".*\w:\s*([+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?)\s*(\w*)")
                        $NWTransferrate = [regex]::matches($data[12], ".*\w:\s*([+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?)\s*(\w*\/\w*)")
                        $AggTransferRate = [regex]::matches($data[13], ".*\w:\s*([+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?)\s*(\w*\/\w*)")
                        $ProcessingTime = [regex]::matches($data[16], ".*\w:\s*(\w+\:\w+\:\w+)")
                        
                        $bytestransfer = $bytestransferred.groups.value[1] + " " + $bytestransferred.groups.value[2]
                        $transtime = $transfertime.groups.value[1] + " " + $transfertime.groups.value[2]
                        $NWTransfer = $NWTransferrate.groups.value[1] + " " + $NWTransferrate.groups.value[2]
                        $AggTransfer = $AggTransferRate.groups.value[1] + " " + $AggTransferRate.groups.value[2]
                        $Processing = $ProcessingTime.groups.value[1] 

                        $info = [ordered]@{ 
                            ComputerName     = $Computer
                            Date             = $Date
                            schedulename     = $schedulename.trim()
                            Inspected        = $inspected.groups.value[1]
                            Backedup         = $backedup.groups.value[1]
                            Failed           = $failed.groups.value[1]
                            BytesTransferred = $bytestransfer
                            TransferTime     = $transtime
                            NWTransferrate   = $NWTransfer
                            AggTransferRate  = $AggTransfer
                            ProcessingTime   = $Processing
                            Status           = "Success"                              
                        } 
                        $statinformation = New-Object PSOBject -Property $info   
                        $statinformation                                   
                    }                      
                    
                                                                      
                }                                    
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName     = $Computer
                        schedulename     = ""
                        Inspected        = ""
                        Backedup         = ""
                        Failed           = ""
                        BytesTransferred = ""
                        TransferTime     = ""
                        NWTransferrate   = ""
                        AggTransferRate  = ""
                        ProcessingTime   = ""         
                        Status           = "$ErrorMessage"  
                    }                         
                    $statinformation = New-Object PSOBject -Property $info   
                    $statinformation                                       
                }    
            }
            else {
                $info = [ordered]@{ 
                    ComputerName     = $Computer
                    schedulename     = ""
                    Inspected        = ""
                    Backedup         = ""
                    Failed           = ""
                    BytesTransferred = ""
                    TransferTime     = ""
                    NWTransferrate   = ""
                    AggTransferRate  = ""
                    ProcessingTime   = ""         
                    Status           = "Computer is not reachable"  
                }                         
                $statinformation = New-Object PSOBject -Property $info   
                $statinformation 
            }   
        }
    }
    End {
    
    }    
}