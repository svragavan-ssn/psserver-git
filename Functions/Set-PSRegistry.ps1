Function Set-PSRegistry {
<#
	.SYNOPSIS
		Sets registry value in local or remote machine.
	
	.DESCRIPTION
		Creates or Sets registry value on in given path from local or remote computer.
        
	.PARAMETER ComputerName
		The target machine name to get the value. Defaults to localhost.
	
	.PARAMETER Hive
		Specify registry Hive name to create the value. Defaults to LocalMachine.Valid values are ClassesRoot,CurrentConfig,CurrentUser,DynData,LocalMachine,PerformanceData and Users
	
	.PARAMETER Regpath
		The path to create the value.If the specified path doesn't exist and parent path exist then the key will be created.If parent path also doesn't exist then function fails.
	
	.PARAMETER ValueName
        Name of the key to create.
        
    .PARAMETER ValueData
        Value to assign.
        
    .PARAMETER Type
        Type of registry key to create.Valid values are String,ExpandString,Binary,DWord,MultiString and QWord
        
    .PARAMETER Append
		To Append the value in existing key.If not used then existing value will be overwritten.    
	
	.EXAMPLE
		Set-PSRegistry -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer -Valuedata "SRVWSUS01.TST.Local" -Type String
		
		Sets Value of WUserver in the given registry path of local computer.
	
	.EXAMPLE
		Set-PSRegistry -ComputerName SRVTST01 -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer -Valuedata "SRVWSUS01.TST.Local" -Type String
		
		Sets Value of WUserver in the given registry path of machine SRVTST01.

    .EXAMPLE
		Set-PSRegistry -Hive CurrentUser -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer -Valuedata "SRVWSUS01.TST.Local" -Type String
        
        Sets Value of WSUS server in CurrentUser registry Hive.
    
    .EXAMPLE
		Get-content .\list.txt | Set-PSRegistry -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer -Valuedata "SRVWSUS01.TST.Local" -Type String
        
        Keep multiple machine name in TXT file to set Value of WSUS server from the given registry path.	    
    
    .EXAMPLE
		Import-Csv  .\list.csv | Set-PSRegistry -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer -Valuedata "SRVWSUS01.TST.Local" -Type String
        
        Keep multiple machine name in CSV file to set Value of WSUS server from the given registry path.	    
    
    .EXAMPLE
		Set-PSRegistry -Regpath "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName WUServer -Valuedata "SRVWSUS01.TST.Local" -Type String -Append
        
        Use append parameter to update the value if the key already exist.If not used then old value will be overwritten
    
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
        [parameter()]
        [ValidateSet("ClassesRoot", "CurrentConfig", "CurrentUser", "DynData", "LocalMachine", "PerformanceData", "Users")]
        [String]$Hive = "LocalMachine",
        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [String]$Regpath,
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()] 
        [String]$ValueName, 
        [parameter(Mandatory = $True)]
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "QWord")]
        [String]$Type,
        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [String]$ValueData,
        [parameter()]
        [Switch]$Append
    )                  
    Begin {
      
    }
    Process {
        foreach ($Computer in $ComputerName) {
            if (Test-connection $computer -count 1 -quiet:$true) {           
                try {
                    $base = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, "$computer")
                    $registry = $base.opensubkey("$Regpath", $True)
                    $oldvalue = $registry.getvalue($ValueName)   
                    if ($registry -eq $null) {
                        Write-verbose "Given key doesn't Exist.Trying to create it"
                        $findparentkey = [regex]::matches($Regpath, ".*\w*\\")
                        $parentkey = $findparentkey.groups.value
                        $findsubkey = [regex]::matches($Regpath, ".*\w*\\(\w*)")
                        $subkey = $findsubkey.groups.value[1]
                        $parentreg = $base.OpenSubKey($parentKey, $true)
                        if ($parentreg -ne $null) {
                            $parentreg.createsubkey($subkey) | Out-Null
                            $registry = $base.opensubkey("$Regpath", $True)
                            Write-verbose "Created $subkey Key"                       
                            $registry.setvalue($ValueName, $ValueData, $type)  
                            $parentreg.close()
                            $registry.close()
                            Write-verbose "Registry value has been set"
                            $info = [ordered]@{
                                ComputerName = $computer
                                ValueName    = $ValueName
                                OldValue     = ""
                                NewValue     = $valueData
                                Status       = "Success"
                            }
                            $registryvalue = New-Object PSOBject -Property $info 
                            $registryvalue                     
                        }
                        else {
                            $info = [ordered]@{
                                ComputerName = $computer
                                ValueName    = "$ValueName"
                                OldValue     = ""
                                NewValue     = ""
                                Status       = "$regpath is not correct"
                            }
                            $registryvalue = New-Object PSOBject -Property $info 
                            $registryvalue
                            Exit
                        }
                    }
                    elseif ($oldvalue -ne $null) {
                        
                        if ($append) {
                            $value = $oldvalue + $Valuedata
                            $registry.setvalue($Name, $value, $type)
                            $registry.close()
                            Write-verbose "Registry value has been set"
                            $info = [ordered]@{
                                ComputerName = $computer
                                ValueName    = $name
                                OldValue     = $oldvalue
                                NewValue     = $value
                                Status       = "Success"
                            }
                            $registryvalue = New-Object PSOBject -Property $info 
                            $registryvalue
                        }
                        else {
                            $registry.setvalue($ValueName, $ValueData, $type)
                            $registry.close()
                            Write-verbose "Registry value has been set"
                            $info = [ordered]@{
                                ComputerName = $computer
                                Name         = $Valuename
                                OldValue     = $oldvalue
                                NewValue     = $ValueData
                                Status       = "Success"
                            }
                            $registryvalue = New-Object PSOBject -Property $info 
                            $registryvalue
                        }
                    }    
                    else {
                        $registry.setvalue($Name, $value, $type)
                        $registry.close()
                        Write-verbose "Registry value has been set"
                        $info = [ordered]@{
                            ComputerName = $computer
                            ValueName    = $ValueName
                            OldValue     = ""
                            NewValue     = $ValueData 
                            Status       = "Success"
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
                        OldValue     = "NA"
                        NewValue     = "NA"
                        Status       = "$ErrorMessage"
                    }
                    $registryvalue = New-Object PSOBject -Property $info 
                    $registryvalue
                }       
                try {   
                    Remove-variable $findparentkey, $parentkey, $findsubkey, $subkey, $parentreg, $registry, $computer, $name, $value, $type
                }
                catch {
                    
                }
            }               
            else {
                $info = [ordered]@{
                    ComputerName = $computer
                    ValueName    = ""
                    OldValue     = ""
                    NewValue     = ""
                    Status       = "Not Reachable"
                }
                $registryvalue = New-Object PSOBject -Property $info 
                $registryvalue
            }
        }
    }
    End {

    }
}