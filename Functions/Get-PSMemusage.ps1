Function Get-PSMemusage {
<#
	.SYNOPSIS
		Gets Memory Usage information.
	
	.DESCRIPTION
		Gets Memory Usage information from Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine name to get the information. Defaults to localhost.
	
	.EXAMPLE
		Get-PSMemusage
		
	    Gets Memory Usage information of local machine.
	
	.EXAMPLE
		Get-PSMemusage -computername SRVTST01,SRVTST02
		
		Gets Memory Usage information of machine SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt | Get-PSMemusage 
        
        Keep multiple machine name in TXT file to get Memory Usage information.
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSMemusage 
        
        Keep multiple machine name in CSV file to get Memory Usage information.The header name must be Computername.
	    
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
					$os = Get-Wmiobject Win32_OperatingSystem -ComputerName $computer
					$Memfree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
 					$server = Get-WmiObject win32_computersystem -ComputerName $Computer -ErrorAction Stop 
					$processinfo=get-process -ComputerName $computer |Select-Object Name,@{Name='WorkingSet';Expression={($_.WorkingSet/1MB)}} |Sort-Object workingset -desc | select -first 1
					
                       $info = [ordered]@{ 
                            ComputerName   = $Computer
                            'FreeMemory %' = $memfree
							'RAM/GB'       = [math]::Round(($server.TotalPhysicalMemory / 1GB), 2)
							Processname    =$processinfo.name
							'MemoryUsage/MB' = $processinfo.workingset
                            Status         = "Success" 
                        }                   
                        $meminformation = New-Object PSOBject -Property $info  
                        $meminformation                                                    
                }  
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName   = $Computer
                        'FreeMemory %'     = ""
                        Status         = "$ErrorMessage" 
                    } 
                    $meminformation = New-Object PSOBject -Property $info  
                    $meminformation
                }    
            }  
            else {
                $info = [ordered]@{ 
                    ComputerName   = $Computer
                    'FreeMemory %'      = ""
                    Status         = "Computer is not Reachable" 
                } 
                $meminformation = New-Object PSOBject -Property $info  
                $meminformation  
            }
        }
    }
    End {

    }
}