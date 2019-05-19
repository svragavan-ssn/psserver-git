Function Get-PSServerStatus {
<#
	.SYNOPSIS
		Provides system disk,uptime,configuration,update and reboot information.
	
	.DESCRIPTION
		Provides disk,uptime,system configuration,update and reboot information of local machine or remote machine.
	
	.PARAMETER ComputerName
		The target machine name to get the information.Defaults to localhost.
	
    .EXAMPLE
		Get-PSServerStatus
		
		Gets the information of local machine.

    .EXAMPLE
		Get-PSServerStatus -computername SRVTST01,SRVTST02
		
		Gets the information from SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt |Get-PSServerStatus
        
        Keep multiple machine name in TXT file to get their information.
    
    .EXAMPLE
		Import-Csv .\list.csv | Get-PSServerStatus
        
        Keep multiple machine name in CSV file to get their information.The header name must be Computername.
	    
	.NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License:  
#> 
    [cmdletbinding()]    
    Param(
        [parameter(Mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [Validatenotnullorempty()]
        [string[]]$ComputerName = "$env:COMPUTERNAME"
    )   
    Begin {

    }
    Process {
        foreach ($computer in $ComputerName) {
            try {
                if ((Test-connection $computer -count 2 -quiet:$true)) {
                    
                    $systemuptime = Get-PSUptime -computername $computer
                    $systemdisk = Get-PSDisk -computername $computer
                    $systemconf = Get-PSServerconfig -computername $computer
                    $systemupdate = get-hotfix -ComputerName $computer | Sort-Object -desc installedon | Select-Object -first 1
                    $systemreboot = Get-PSRebootStatus -computername $computer

                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        OS=$systemconf.OperatingSystem
                        Processorname=$systemconf.Processorname
                        Manufacturer=$systemconf.Manufacturer
                        Drivename=$systemdisk.Drivename
                        'FreeSpace %'=$systemdisk.'FreeSpace %'
                        'RAM/GB'=$systemconf.'RAM/GB'
                        'Update Installedon'=$systemupdate.Installedon
                        BootTime=$systemuptime.BootTime
                        Uptime=$systemuptime.Uptime
                        LastReboot=$systemreboot.date
                        RebootBy= $systemreboot.RebootBy
                        Status= "Success"     
                    }

                    $systemstatus = New-Object PSOBject -Property $info
                    $systemstatus

                }
                else {
                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        OS=""
                        Processorname=""
                        Manufacturer=""
                        Drivename=""
                        'FreeSpace %'=""
                        'RAM/GB'=""
                        'Update Installedon'=""
                        BootTime=""
                        Uptime=""
                        LastReboot=""
                        RebootBy="" 
                        Status= "Computer is not reachable"
                    } 
                    $systemstatus = New-Object PSOBject -Property $info
                    $systemstatus
                }
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                $info = [ordered]@{ 
                    ComputerName = $Computer
                    OS=""
                    Processorname=""
                    Manufacturer=""
                    Drivename=""
                    'FreeSpace %'=""
                    'RAM/GB'=""
                    'Update Installedon'=""
                    BootTime=""
                    Uptime=""
                    LastReboot=""
                    RebootBy="" 
                    Status= $Errormessage
                } 
                $systemstatus = New-Object PSOBject -Property $info
                $systemstatus
            }
        }
    }
    End {

    }
}