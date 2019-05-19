Function Get-PSUptime {
<#
	.SYNOPSIS
		Gets the number of days since the machine is up
	
	.DESCRIPTION
		Gets the number of days since the machine is up from local machine or remote machine.
	
	.PARAMETER ComputerName
		The target machine name to get the information.Defaults to localhost.
	
    .EXAMPLE
		Get-PSUptime
		
		Gets the information of local machine.

    .EXAMPLE
		Get-PSUptime -computername SRVTST01,SRVTST02
		
		Gets the information from SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt | Get-PSUptime
        
        Keep multiple machine name in TXT file to get their information.
    
    .EXAMPLE
		Import-Csv .\list.csv | Get-PSUptime
        
        Keep multiple machine name in CSV file to get their information.The header name must be Computername.
	    
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
        Foreach ($Computer in $ComputerName) { 
            if (Test-connection $computer -count 2 -quiet:$true) {
                try {                  
                    $system = Get-WmiObject win32_operatingsystem -ComputerName $Computer -ErrorAction Stop
                    $boot = $system.ConvertToDateTime($system.LastBootUpTime) 
                    $serveruptime = $system.ConvertToDateTime($system.LocalDateTime) - $boot 
                    $updays = $serveruptime.days
                    $uphours = $serveruptime.Hours
                    $upminutes = $serveruptime.Minutes
                    $up = "$updays Days $uphours Hours and $upminutes Minutes"
                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        BootTime     = $boot
                        Uptime       = $up
                        Status       = "Success"
                    } 
                    $systemuptime = New-Object PSOBject -Property $info 
                    $systemuptime 
                }  
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        BootTime     = ""
                        Uptime       = ""
                        Status       = $Errormessage
                    } 
                    $systemuptime = New-Object PSOBject -Property $info 
                    $systemuptime 
                }    
            }  
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer
                    BootTime     = ""
                    Uptime       = ""
                    Status       = "Computer is not reachable"
                } 
                $systemuptime = New-Object PSOBject -Property $info 
                $systemuptime 
            }
        }
    }    
    End {
        
    }
}