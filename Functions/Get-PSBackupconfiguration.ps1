Function Get-PSBackupconfiguration {
    <#
        .SYNOPSIS
            Gets backup configuration of a machine.
        
        .DESCRIPTION
            Gets backup configuration from given machine.Configuration includes backup servername and volumes included to take backup.
        
        .PARAMETER ComputerName
            The target machine name to get the information. Defaults to localhost.

        .PARAMETER Cluster
            To get backup configuration information of cluster disks as well.

        .EXAMPLE
            Get-PSBackupconfiguration
            
            Gets backup configuration from local machine.
        
        .EXAMPLE
           Get-PSBackupconfiguration-computername SRVTST01,SRVTST02
            
           Gets backup configuration from machine SRVTST01 and SRVTST02. 
           
        .EXAMPLE
           Get-PSBackupconfiguration-computername SRVTST01 -cluster
            
           Gets backup configuration from machine SRVTST01 and if it is cluster server then it will get backup configuration of all disks.

        .EXAMPLE
            Get-content .\list.txt | Get-PSBackupconfiguration
            
            Keep multiple machine name in TXT file to get their backup configuration.
        
        .EXAMPLE
            Import-Csv  .\list.csv | Get-PSBackupconfiguration
            
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
        [parameter(ParameterSetName = "Cluster")]   
        [string[]]$computername = $env:COMPUTERNAME, 
        [parameter(ParameterSetName = "Cluster")]   
        [switch]$cluster            
    )
    Begin {
    
    }        
    Process {
        foreach ($Computer in $ComputerName) {

            if (Test-connection $computer -count 1 -quiet:$true) {   
                
                if ($PsCmdlet.ParameterSetName -eq "Cluster") {
                    try {                        
                        if (get-service -ComputerName $computer -name clussvc -ErrorAction SilentlyContinue) {
                            $disks = get-psdisk -computername $Computer                               
                            foreach ($disk in $disks) {
                                try {
                                    $dsk = $disk.drivename.Substring(0, 1)
                                   
                                    if ($dsk -ne "c") {                                                                             
                                        $content = Get-Content "\\$computer\$dsk$\TSM\dsm.opt" -ErrorAction Stop                                            
                                        if ($content) {
                                            $Node = [regex]::matches($content, ".NODENAME\s*(\w*)", "IgnoreCase")
                                            $nodename = $node.groups.value[1]
                                            $getserver = [regex]::matches($content, ".TCPSERVERADDRESS\s*(\w*)", "IgnoreCase")
                                            $backupserver = $getserver.groups.value[1]
                                            $getdomain = [regex]::matches($content, ".DOMAIN\s*(\w*)", "IgnoreCase")
                               
                                            foreach ($domain in $getdomain) {
                                                $dom += $domain.Groups.value[1]
                                                $dom += ":"
                                            }
                                            $info = [ordered]@{ 
                                                ComputerName     = $Computer    
                                                NodeName         = $Nodename                                    
                                                BackupServername = $backupserver   
                                                BackupIncluded   = $dom                                             
                                                Status           = "Success"
                                            } 
                                            $backupinformation = New-Object PSOBject -Property $info   
                                            $backupinformation
                                            $dom = ""
                                        }                                                                               
                                    }
                                    else {                                       
                                        $content = Get-Content "\\$computer\c$\Program Files\Tivoli\TSM\baclient\dsm.opt" -ErrorAction Stop                                            
                                        if ($content) {
                                            $Node = [regex]::matches($content, ".NODENAME\s*(\w*)", "IgnoreCase")
                                            $nodename = $node.groups.value[1]
                                            $getserver = [regex]::matches($content, ".TCPSERVERADDRESS\s*(\w*)", "IgnoreCase")
                                            $backupserver = $getserver.groups.value[1]
                                            $getdomain = [regex]::matches($content, ".DOMAIN\s*(\w*)", "IgnoreCase")
                           
                                            foreach ($domain in $getdomain) {
                                                $dom += $domain.Groups.value[1]
                                                $dom += ":"
                                            }
                                            $info = [ordered]@{ 
                                                ComputerName     = $Computer 
                                                NodeName         = $Nodename                                                     
                                                BackupServername = $backupserver   
                                                BackupIncluded   = $dom                                             
                                                Status           = "Success"
                                            } 
                                            $backupinformation = New-Object PSOBject -Property $info   
                                            $backupinformation
                                            $dom = ""
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
                        $content = Get-Content "\\$computer\c$\Program Files\Tivoli\TSM\baclient\dsm.opt" -ErrorAction Stop 
                            
                        if ($content) {
                            $Node = [regex]::matches($content, ".NODENAME\s*(\w*)", "IgnoreCase")
                            $nodename = $node.groups.value[1]
                            $getserver = [regex]::matches($content, ".TCPSERVERADDRESS\s*(\w*)", "IgnoreCase")
                            $backupserver = $getserver.groups.value[1]
                            $getdomain = [regex]::matches($content, ".DOMAIN\s*(\w*)", "IgnoreCase")
            
                            foreach ($domain in $getdomain) {
                                $dom += $domain.Groups.value[1]
                                $dom += ":"
                            }
                            $info = [ordered]@{ 
                                ComputerName     = $Computer    
                                NodeName         = $Nodename                                    
                                BackupServername = $backupserver   
                                BackupIncluded   = $dom                                             
                                Status           = "Success"
                            } 
                            $backupinformation = New-Object PSOBject -Property $info   
                            $backupinformation
                            $dom = ""
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