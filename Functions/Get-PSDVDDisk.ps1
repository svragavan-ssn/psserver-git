Function Get-PSDVDDisk {
    <#
        .SYNOPSIS
            Gets Removeable drive DVD Disk information.
        
        .DESCRIPTION
            Gets Removeable drive DVD Disk from Local machine or Remote machine.
        
        .PARAMETER ComputerName
            The target machine name to get the information. Defaults to localhost.
        
        .EXAMPLE
            Get-PSDVDDisk
            
            Gets removable drive letter information from local machine.
        
        .EXAMPLE
            Get-PSDVDDisk -computername SRVTST01,SRVTST02
            
            Gets removable drive letter information from machines SRVTST01 and SRVTST02.
    
        .EXAMPLE
            Get-content .\list.txt | Get-PSDVDDisk
            
            Keep multiple machine name in TXT file to get removable drive letter information.
        
        .EXAMPLE
            Import-Csv  .\list.csv | Get-PSDVDDisk
            
            Keep multiple machine name in CSV file to get removable drive letter information.The header name must be Computername.
            
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
            [string[]]$computername = $env:COMPUTERNAME
        )
        Begin {
    
        }        
        Process {
            foreach ($Computer in $ComputerName) {
                if (Test-connection $computer -count 1 -quiet:$true) {
                    try {                 
                        $disks = Get-WmiObject Win32_volume -ComputerName $Computer -filter "drivetype='5'" -ErrorAction Stop  
                        foreach ($disk in $disks) {
                            $info = [ordered]@{ 
                                ComputerName   = $Computer
                                Drivename      = $disk.DriveLetter                        
                                Status         = "Success" 
                            }                   
                            $diskinformation = New-Object PSOBject -Property $info  
                            $diskinformation    
                        }                                  
                    }  
                    catch { 
                        $ErrorMessage = $_.Exception.Message
                        $info = [ordered]@{ 
                            ComputerName   = $Computer
                            Drivename      = ""                            
                            Status         = "$ErrorMessage" 
                        } 
                        $diskinformation = New-Object PSOBject -Property $info  
                        $diskinformation
                    }    
                }  
                else {
                    $info = [ordered]@{ 
                        ComputerName   = $Computer
                        Drivename      = ""                        
                        Status         = "Computer is not Reachable" 
                    } 
                    $diskinformation = New-Object PSOBject -Property $info  
                    $diskinformation  
                }
            }
        }
        End {
    
        }
    }