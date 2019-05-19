Function Set-PSBackupconfiguration {
    <#
        .SYNOPSIS
            Sets backup configuration of a machine.
        
        .DESCRIPTION
            Sets backup configuration on given machine.Configures backup servername.
        
        .PARAMETER ComputerName
            The target machine name to set the information. Defaults to localhost.

        .PARAMETER Cluster
            To get backup configuration information of cluster disks as well.

         .PARAMETER BackupServer
            To get backup configuration information of cluster disks as well.    

        .EXAMPLE
            Set-PSBackupconfiguration
            
            Sets backup configuration from local machine.
        
        .EXAMPLE
           Set-PSBackupconfiguration-computername SRVTST01,SRVTST02
            
           Sets backup configuration from machine SRVTST01 and SRVTST02. 
           
        .EXAMPLE
           Set-PSBackupconfiguration-computername SRVTST01 -cluster
            
           Gets backup configuration from machine SRVTST01 and if it is cluster server then it will get backup configuration of all disks.

        .EXAMPLE
            Get-content .\list.txt | Set-PSBackupconfiguration
            
            Keep multiple machine name in TXT file to get their backup configuration.
        
        .EXAMPLE
            Import-Csv  .\list.csv | Set-PSBackupconfiguration
            
            Keep multiple machine name in CSV file to get their backup configuration.
            
        .NOTES
            Author: Vijayaragavan S (@Ragavanvs)
            Tags: 
            
            Website: 
            Copyright: (C) Vijayaragavan
            License:  
    #>     
    [cmdletbinding(DefaultParameterSetName = "Default")]
    param (    
        [parameter(Mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = "Default")]        
        [string[]]$computername = $env:COMPUTERNAME, 
        [parameter(Mandatory = $True, ParameterSetName = "Default")]   
        [String]$backupserver,
        [parameter(ParameterSetName = "Cluster")]   
        [switch]$cluster,
        [parameter(Mandatory = $True, ParameterSetName = "Cluster")]   
        [String[]]$diskname
    )
    Begin {
    
    }        
    Process {
        foreach ($Computer in $ComputerName) {

            if (Test-connection $computer -count 1 -quiet:$true) {   
                
                if ($PsCmdlet.ParameterSetName -eq "Cluster") {
                    try {                        
                        if (get-service -ComputerName $computer -name clussvc -ErrorAction SilentlyContinue) {
                                     
                            foreach ($ds in $diskname) {
                                try {                                                                                                         
                                    if ($ds -ne "c") {                                                                             
                                        $content = Get-Content "\\$computer\$ds$\TSM\dsm.opt" -ErrorAction Stop                                            
                                        if ($content) {
                                            $date = get-date -uformat "%Y-%m-%d-%H-%M"     
                                            New-Item -itemtype file -path "\\$computer\$dsk$\TSM\dsm_$date.opt" | Set-Content -Value $content 
                                            $Node = [regex]::matches($content, ".NODENAME\s*(\w*)", "IgnoreCase")
                                            $nodename = $node.groups.value[1]
                                            $getserver = [regex]::matches($content, ".TCPSERVERADDRESS\s*(\w*)", "IgnoreCase")
                                            $oldbackupserver = $getserver.groups.value[1]                           
                                            ($content).replace($oldbackupserver, $backupserver) | Set-Content "\\$computer\$dsk$\TSM\dsm.opt"
                                                
                                            $info = [ordered]@{ 
                                                ComputerName    = $Computer    
                                                NodeName        = $Nodename  
                                                OldBackupserver = $oldbackupserver                                
                                                BackupServer    = $backupserver                                                               
                                                Status          = "Success"
                                            } 
                                            $backupinformation = New-Object PSOBject -Property $info   
                                            $backupinformation 
                                        }                                                                               
                                    }
                                    else {                                       
                                        $content = Get-Content "\\$computer\c$\Program Files\Tivoli\TSM\baclient\dsm.opt" -ErrorAction Stop                                            
                                        if ($content) {
                                            $date = get-date -uformat "%Y-%m-%d-%H-%M"     
                                            New-Item -itemtype file -path "\\$computer\c$\Program Files\Tivoli\TSM\baclient\dsm_$date.opt" | Set-Content -Value $content 
                                            $Node = [regex]::matches($content, ".NODENAME\s*(\w*)", "IgnoreCase")
                                            $nodename = $node.groups.value[1]
                                            $getserver = [regex]::matches($content, ".TCPSERVERADDRESS\s*(\w*)", "IgnoreCase")
                                            $oldbackupserver = $getserver.groups.value[1]                           
                                            ($content).replace($oldbackupserver, $backupserver) | Set-Content "\\$computer\c$\Program Files\Tivoli\TSM\baclient\dsm.opt"  
                                                
                                            $info = [ordered]@{ 
                                                ComputerName    = $Computer    
                                                NodeName        = $Nodename  
                                                OldBackupserver = $oldbackupserver                                
                                                BackupServer    = $backupserver                                                               
                                                Status          = "Success"
                                            } 
                                            $backupinformation = New-Object PSOBject -Property $info   
                                            $backupinformation
                                        } 
                                    }                                                                         
                                } 
                                catch {                    
                                    $ErrorMessage = $_.Exception.Message 
                                    $info = [ordered]@{ 
                                        ComputerName     = $Computer
                                        NodeName         = ""                                                   
                                        BackupServername = ""    
                                        BackupIncluded   = ""                                                                  
                                        Status           = "$ErrorMessage"
                                    }
                                    $backupinformation = New-Object PSOBject -Property $info   
                                    $backupinformation                            
                                }                                                                                          
                            }    
                        } 
                        else {                            
                            $info = [ordered]@{ 
                                ComputerName     = $Computer   
                                Nodename         = ""                                       
                                BackupServername = "" 
                                BackupIncluded   = ""                                     
                                Status           = "Not a cluster Server"
                            } 
                            $backupinformation = New-Object PSOBject -Property $info   
                            $backupinformation
                        }                                                                                                                                                                                                                           
                    }
                    catch {
                        $ErrorMessage = $_.Exception.Message
                        $info = [ordered]@{ 
                            ComputerName     = $Computer  
                            Nodename         = ""                                        
                            BackupServername = ""
                            BackupIncluded   = ""                                   
                            Status           = $ErrorMessage
                        } 
                        $backupinformation = New-Object PSOBject -Property $info   
                        $backupinformation
                    }                       
                }
                else {                    
                    try {                        
                        
                        $content = get-content -path "d:\ragavan\TSM\dsm.opt" -ErrorAction Stop                                                

                        if ($content) {
                            $date = get-date -uformat "%Y-%m-%d-%H-%M"     
                            New-Item -itemtype file -path "D:\Ragavan\TSM\dsm_$date.opt" | Set-Content -Value $content 
                            $Node = [regex]::matches($content, ".NODENAME\s*(\w*)", "IgnoreCase")
                            $nodename = $node.groups.value[1]
                            $getserver = [regex]::matches($content, ".TCPSERVERADDRESS\s*(\w*)", "IgnoreCase")
                            $oldbackupserver = $getserver.groups.value[1]                           
                            ($content).replace($oldbackupserver, $backupserver) | Set-Content D:\Ragavan\TSM\dsm-new.opt     
                            
                            $info = [ordered]@{ 
                                ComputerName    = $Computer    
                                NodeName        = $Nodename  
                                OldBackupserver = $oldbackupserver                                
                                BackupServer    = $backupserver                                                               
                                Status          = "Success"
                            } 
                            $backupinformation = New-Object PSOBject -Property $info   
                            $backupinformation                            
                        }                                                                   
                    }
                    catch {
                        $ErrorMessage = $_.Exception.Message 
                        $info = [ordered]@{ 
                            ComputerName     = $Computer
                            NodeName         = ""                                                   
                            BackupServername = ""    
                            BackupIncluded   = ""                                                                  
                            Status           = "$ErrorMessage"
                        }
                        $backupinformation = New-Object PSOBject -Property $info   
                        $backupinformation  
                    }                    
                }
            }             
            else {                
                $info = [ordered]@{ 
                    ComputerName     = $Computer
                    NodeName         = ""
                    BackupServername = ""
                    BackupIncluded   = ""                                                 
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