Function Get-PSDisk {
<#
	.SYNOPSIS
		Gets Disk Space information.
	
	.DESCRIPTION
		Gets Disk Space information from Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine name to get the information. Defaults to localhost.
	
	.EXAMPLE
		Get-PSDisk
		
	    Gets Total,Used and Free Disk Space information of local machine.
	
	.EXAMPLE
		Get-PSDisk -computername SRVTST01,SRVTST02
		
		Gets Total,Used and Free Disk Space information of machine SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt | Get-PSDisk
        
        Keep multiple machine name in TXT file to get Total,Used and Free Disk Space information.
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSDisk
        
        Keep multiple machine name in CSV file to get Total,Used and Free Disk Space information.The header name must be Computername.
	    
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
                    $disks = Get-WmiObject Win32_volume -ComputerName $Computer -filter "drivetype='3'" -ErrorAction Stop  
                    foreach ($disk in $disks) {
                        $info = [ordered]@{ 
                            ComputerName   = $Computer
                            Driveletter      = $disk.DriveLetter
                            Drivelabel     = $disk.Label
                            'TotalSize/GB' = [math]::round(($disk.Capacity / 1GB), 2)
                            'UsedSpace/GB' = [math]::round(($disk.Capacity - $disk.freespace) / 1GB, 2)
                            'FreeSpace/GB' = [math]::round(($disk.freespace / 1GB), 2)
                            'FreeSpace %'  = [math]::round((($disk.freespace / $disk.Capacity) * 100), 2)
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
                        Drivelabel     = ""
                        'TotalSize/GB' = ""
                        'UsedSpace/GB' = ""
                        'FreeSpace/GB' = ""
                        'FreeSpace %'  = ""
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
                    Drivelabel     = ""
                    'TotalSize/GB' = ""
                    'UsedSpace/GB' = ""
                    'FreeSpace/GB' = ""
                    'FreeSpace %'  = ""
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