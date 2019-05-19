Function Set-PSService {
<#
	.SYNOPSIS
		Sets service status from local or remote machine.
	
	.DESCRIPTION
		Sets service status of given path from local or remote computer.
        
	.PARAMETER ComputerName
		The target machine name to set the service status. Defaults to localhost.
	
	.PARAMETER ServiceName
        Specify the service name to set the status.By The parameter is mandatory.
        
    .PARAMETER Status
        Provide the status the  service needs to be assigned.Default value is running.
    
    .PARAMETER Startup
		Specify to set startup type of the service.Defaults value is Automatic
			
	.EXAMPLE
		Set-PSService -computername srvtst01 -servicename wuauserv
		
		Sets Windows update service status to Running and startup type to Automatic in computer SRVTST01.

    .EXAMPLE
        Set-PSService -computername srvtst01 -servicename wuauserv -status Stop
        
        Sets Windows update service status to Stop and startup type to Automatic in computer SRVTST01.
    
    .EXAMPLE
		Set-PSService -computername srvtst01 -servicename wuauserv -status Stop -startup disabled
        
        Sets Windows update service status to Stop and startup type to Disabled in computer SRVTST01.	    
    
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
        [parameter(Mandatory = $True)]
        [string]$servicename,
        [parameter(Mandatory = $false)]
        [ValidateSet("Running", "Stopped", "Paused")]
        [string]$status = "Running",
        [parameter(Mandatory = $false)]
        [ValidateSet("Boot", "System", "Automatic", "Manual", "Disabled")]
        [string]$startup = "Automatic"     
    )
    Begin {

    }
    Process {
        Foreach ($computer in $computername) {
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {
                    
                    if ($pscmdlet.PSBoundParameters -contains "startup") {
                        $details = Get-Service -Name $servicename -ComputerName $computer -ErrorAction stop | select-object machinename, servicename, status
                        $stype = (Get-WmiObject -Class Win32_Service -ComputerName $computer -Property StartMode -Filter "Name='$servicename'").startmode                    
                        Set-Service -name $servicename -ComputerName $computer -status $status -ErrorAction stop 
                        $afdetails = Get-Service -Name $servicename -ComputerName $computer -ErrorAction stop | select-object machinename, servicename, status
                        $info = [ordered] @{
                            ComputerName = $details.machinename
                            servicename  = $details.servicename
                            StarttupType = $stype
                            Before       = $details.status
                            After        = $afdetails.status
                            Status       = "Success"
                        } 
                        $serviceinformation = New-Object PSOBject -Property $info
                        $serviceinformation                        
                    }
                    else {
                        $details = Get-Service -Name $servicename -ComputerName $computer -ErrorAction stop | select-object machinename, servicename, status                        
                        Set-Service -name $servicename -ComputerName $computer -status $status -startuptype $startup -ErrorAction stop 
                        $afdetails = Get-Service -Name $servicename -ComputerName $computer -ErrorAction stop | select-object machinename, servicename, status
                        $stype = (Get-WmiObject -Class Win32_Service -ComputerName $computer -Property StartMode -Filter "Name='$servicename'").startmode                    
                        $info = [ordered] @{
                            ComputerName = $details.machinename
                            servicename  = $details.servicename
                            StarttupType = $stype
                            Before       = $details.status
                            After        = $afdetails.status
                            Status       = "Success"
                        } 
                        $serviceinformation = New-Object PSOBject -Property $info
                        $serviceinformation
                    }                                        
                } 
                catch {
                    $ErrorMessage = $_.Exception.Message                   
                    $info = [ordered] @{
                        ComputerName = $computer
                        servicename  = $servicename
                        StarttupType = ""
                        Before       = ""
                        After        = ""     
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
                    StarttupType = ""
                    Before       = ""
                    After        = ""     
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