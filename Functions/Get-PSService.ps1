Function Get-PSService {
<#
	.SYNOPSIS
		Gets service status from local or remote machine.
	
	.DESCRIPTION
		Gets service status of given path from local or remote computer.
        
	.PARAMETER ComputerName
		The target machine name to get the service status. Defaults to localhost.
	
	.PARAMETER ServiceName
		Specify the service name to get it status.By Default gets all services.
		
	.EXAMPLE
		Get-PSService 
		
		Gets status of all services from local computer.
	
	.EXAMPLE
		Get-PSService -computername srvtst01
		
		Gets status of all services from computer SRVTST01.

    .EXAMPLE
		Get-PSService -computername srvtst01 -servicename wuauserv
        
        Gets status of windows update service from computer SRVTST01.
    
    .EXAMPLE
		Get-content .\list.txt | Get-PSService -servicename wuauserv
        
        Keep multiple machine name in TXT file to get windows update service status.	    
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSRegistry -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        
        Keep multiple machine name in TXT file to get windows update service status.
    
    .NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License: 
#>
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$computername = $env:COMPUTERNAME,
        [parameter()]
        [string[]]$servicename = "*"          
    )
    Begin {

    }
    Process {
        Foreach ($computer in $computername) {
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {
                    $details = Get-Service -Name $servicename -ComputerName $computer -ErrorAction stop | select-object machinename, servicename, status
                    $servname=$details.servicename
                    $stype = (Get-WmiObject -Class Win32_Service -ComputerName $computer -Property StartMode -Filter "Name='$servname'").startmode                    
                    $info = [ordered] @{
                        ComputerName = $details.machinename
                        servicename  = $details.servicename
                        Startuptype  = $stype
                        Status       = $details.status
                    } 
                    $serviceinformation = New-Object PSOBject -Property $info
                    $serviceinformation
                } 
                catch {
                    $ErrorMessage = $_.Exception.Message                   
                    $info = [ordered] @{
                        ComputerName = $computer
                        servicename  = $servicename
                        Startuptype  = ""
                        Status       = $ErrorMessage
                    } 
                    $serviceinformation = New-Object PSOBject -Property $info
                    $serviceinformation
                }                              
            }
            else {               
                $info = [ordered] @{
                    ComputerName = $computer
                    servicename  = ""
                    Startuptype  = ""
                    Status       = "Computer is not reachable"
                } 
                $serviceinformation = New-Object PSOBject -Property $info
                $serviceinformation
            }     
        }
    }
    End {

    }
}