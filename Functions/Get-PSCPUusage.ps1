Function Get-PSCPUusage {
<#
	.SYNOPSIS
		Gets CPU Usage information.
	
	.DESCRIPTION
		Gets CPU Usage information from Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine name to get the information. Defaults to localhost.
	
	.EXAMPLE
		Get-PSCPUusage
		
	    Gets CPU Usage information of local machine.
	
	.EXAMPLE
		Get-PSCPUusage -computername SRVTST01,SRVTST02
		
		Gets CPU Usage information of machine SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt | Get-PSCPUusage
        
        Keep multiple machine name in TXT file to Get CPU Usage information.
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSCPUusage
        
        Keep multiple machine name in CSV file to get CPU Usage information.The header name must be Computername.
	    
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
                    $cpucore = Get-WmiObject Win32_Processor -ComputerName $Computer |select-object pscomputername,loadpercentage -ErrorAction Stop  
                    foreach ($core in $cpucore) {
                        $info = [ordered]@{ 
                            ComputerName   = $Computer
                            CPUUsage     = $core.loadpercentage
                            Status         = "Success" 
                        }                   
                        $cpuinformation = New-Object PSOBject -Property $info  
                        $cpuinformation    
                    }                                  
                }  
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName   = $Computer
                        CPUUsage       = ""
                        Status         = "$ErrorMessage" 
                    } 
                    $cpuinformation = New-Object PSOBject -Property $info  
                    $cpuinformation
                }    
            }  
            else {
                $info = [ordered]@{ 
                    ComputerName   = $Computer
                    CPUUsage      = ""
                    Status         = "Computer is not Reachable" 
                } 
                $cpuinformation = New-Object PSOBject -Property $info  
                $cpuinformation  
            }
        }
    }
    End {

    }
}