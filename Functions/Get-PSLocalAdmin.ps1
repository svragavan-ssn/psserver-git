Function Get-PSLocalAdmin {
<#
	.SYNOPSIS
		To get list of members added in local administrators group.
	
	.DESCRIPTION
		Gets list of members added in local administrators group from Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine to get members. Defaults to localhost.
	
	.EXAMPLE
		Get-PSLocalAdmin
		
		Gets members of Local Administrators group on local computer.
	
	.EXAMPLE
		Get-PSLocalAdmin -computername SRVTST01,SRVTST02
		
        Gets members of Local Administrators group from remote machines SRVTST01 and SRVTST02.Pass multiple servers by using comma.
        
    .EXAMPLE
		Get-content .\list.txt | Get-PSLocalAdmin
        
        Keep multiple machine name(s) in TXT file to get the members list from more than one machine.
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSIPtoName
        
        Keep multiple machine name(s) in CSV file to get the members list from more than one machine.Header name must be computername.
		    
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
        [string[]]$computername = $env:COMPUTERNAME
    )                  
    Begin {
      
    }
    Process {
        foreach ($Computer in $ComputerName) {
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {
                    $objects = $null
                    $members = [ADSI]"WinNT://$Computer/Administrators"
                    $members = @($members.psbase.Invoke("Members"))
                    foreach ($member in $members) {
                        $User = $member.GetType().InvokeMember("Name", 'GetProperty', $null, $member, $null)
                        $objects += $User
                        $objects += ","
                    }
                    $info = [ordered]@{
                        Name          = $computer
                        "LocalAdmins" = $objects
                        Status        = "Success"
                    }
                    $localadmins = New-Object PSOBject -Property $info 
                    $localadmins
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{
                        Name          = $computer
                        "LocalAdmins" = "NA"
                        Status        = "$ErrorMessage"
                    }
                    $localadmins = New-Object PSOBject -Property $info 
                    $localadmins
                }
            }
            else {
                $info = [ordered]@{
                    Name          = $computer
                    "LocalAdmins" = "NA"
                    Status        = "Computer is not Reachable"
                }
                $localadmins = New-Object PSOBject -Property $info 
                $localadmins
            }
        }
    }
    End {

    }
}