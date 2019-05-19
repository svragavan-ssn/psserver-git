Function Set-PSDVDDiskletter {
    <#
        .SYNOPSIS
            Changes removeable drive DVD Disk drive letter to P.
        
        .DESCRIPTION
            Changes removeable drive DVD Disk drive letter to P on Local machine or Remote machine.
        
        .PARAMETER ComputerName
            The target machine name to change the drive letter. Defaults to localhost.
        
        .EXAMPLE
            Get-PSDVDDisk
            
            Changes removable drive's letter on local machine.
        
        .EXAMPLE
            Get-PSDVDDisk -computername SRVTST01,SRVTST02
            
            Changes removable drive's letter on machines SRVTST01 and SRVTST02.
    
        .EXAMPLE
            Get-content .\list.txt | Get-PSDVDDisk
            
            Keep multiple machine name in TXT file to change removable drive's letter.
        
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
                    $disks = @(Get-WmiObject Win32_volume -ComputerName $Computer -filter "drivetype='5'" -ErrorAction Stop)

                    if ($disks.count -le 1) {
                            
                        Set-WmiInstance -input $disks[0] -Arguments @{DriveLetter = "P:"} | out-null

                        $info = [ordered]@{ 
                            ComputerName   = $Computer
                            OldDriveLetter = $disks[0].DriveLetter
                            NewriveLetter  = "P:"                   
                            Status         = "Success" 
                        }                   
                        $diskinformation = New-Object PSOBject -Property $info  
                        $diskinformation
                    }

                    else {
                        $info = [ordered]@{ 
                            ComputerName   = $Computer
                            OldDriveLetter = ""
                            NewriveLetter  = ""                           
                            Status         = "More than one Removable disks are available" 
                        }                   
                        $diskinformation = New-Object PSOBject -Property $info  
                        $diskinformation    
                    }                                  
                }  
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName   = $Computer
                        OldDriveLetter = ""
                        NewriveLetter  = ""                             
                        Status         = "$ErrorMessage" 
                    } 
                    $diskinformation = New-Object PSOBject -Property $info  
                    $diskinformation
                }    
            }  
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer
                    Drivename    = ""                        
                    Status       = "Computer is not Reachable" 
                } 
                $diskinformation = New-Object PSOBject -Property $info  
                $diskinformation  
            }
        }
    }
    End {
    
    }
}