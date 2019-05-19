Function Get-PSRegistry {
<#
	.SYNOPSIS
		Gets registry value from local or remote machine.
	
	.DESCRIPTION
		Gets registry value of given path from local or remote computer.
        
	.PARAMETER ComputerName
		The target machine name to get the value. Defaults to localhost.
	
	.PARAMETER Hive
		Specify registry Hive name to search the value. Defaults to LocalMachine.Valid values are ClassesRoot,CurrentConfig,CurrentUser,DynData,LocalMachine,PerformanceData and Users
	
	.PARAMETER Regpath
		The path to find the value.The key must exist in the path
	
	.PARAMETER ValueName
		Name of the key to find the value.
	
	.EXAMPLE
		Get-PSRegistry -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer
		
		Gets Value of WUserver from the given registry path of local computer.
	
	.EXAMPLE
		Get-PSRegistry -ComputerName SRVTST01 -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer
		
		Gets Value of WUserver from the given registry path of machine SRVTST01.

    .EXAMPLE
		Get-PSRegistry -Hive CurrentUser -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer
        
        Gets Value of WSUS server from the current user registry path.
    
    .EXAMPLE
		Get-content .\list.txt | Get-PSRegistry -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        
        Keep multiple machine name in TXT file to get Value of WSUS server from the given registry path.	    
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSRegistry -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        
        Keep multiple machine name in CSV file to get Value of WSUS server from the given registry path.	    
    
    .NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License: 
#>
    [cmdletbinding()]
    Param(
        [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$computername = $env:COMPUTERNAME,
        [parameter(Mandatory = $false)]
        [ValidateSet("ClassesRoot", "CurrentConfig", "CurrentUser", "DynData", "LocalMachine", "PerformanceData", "Users")]
        [String]$Hive = "LocalMachine",
        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [String]$Regpath,
        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [String]$ValueName
    )                  
    Begin {
      
    }
    Process {
        foreach ($Computer in $ComputerName) {
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {
                    $base = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, "$computer")
                    $registry = $base.opensubkey("$Regpath")
                    if ($registry -ne $null) {
                        $data = $registry.GetValue("$ValueName")
                        $registry.close()
                        if ($data -ne $null) {
                            $info = [ordered]@{
                                ComputerName = $computer
                                ValueName    = $ValueName
                                ValueData    = $data
                                Status       = "Success"
                            }
                            $registryvalue = New-Object PSOBject -Property $info 
                            $registryvalue
                        }    
                        else {
                            $info = [ordered]@{
                                ComputerName = $computer
                                ValueName    = $ValueName
                                ValueData    = ""
                                Status       = "$ValueName doesn't exist"
                            }
                            $registryvalue = New-Object PSOBject -Property $info 
                            $registryvalue
                        }
                    }
                    else {
                        $info = [ordered]@{
                            ComputerName = $computer
                            ValueName    = $ValueName
                            ValueData    = ""
                            Status       = "$regpath doesn't exist"
                        }
                        $registryvalue = New-Object PSOBject -Property $info 
                        $registryvalue
                    }
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{
                        ComputerName = $computer
                        ValueName    = $ValueName
                        ValueData    = ""
                        Status       = $ErrorMessage
                    }
                    $registryvalue = New-Object PSOBject -Property $info 
                    $registryvalue
                }
            } 
            else {
                $info = [ordered]@{
                    ComputerName = $computer
                    ValueName    = $ValueName
                    ValueData    = ""
                    Status       = "Computer is not reachable"
                }
                $registryvalue = New-Object PSOBject -Property $info 
                $registryvalue
            }
        }
    }
    End {

    }
}