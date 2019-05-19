Function New-PSLocalAdmin {
<#
	.SYNOPSIS
		Creates local user account and adds in local Administrators group.
	
	.DESCRIPTION
		Creates new local user account and adds in local Administrators group of local machine or remote machine.
	
	.PARAMETER ComputerName
		The target machine name to add the account. Defaults to localhost.
	
	.PARAMETER Username
		Specify the account name to be created.Default account name is Dummy.
	
	.PARAMETER Pass
		Specify the password to set for the account.The valus is mandatory and should not be null.
	
	.EXAMPLE
		New-PSLocalAdmin -pass "Spring123"
		
		Creates default user account Dummy in local computer.
	
	.EXAMPLE
		Get-content .\list.txt | New-PSLocalAdmin -username newadmin -Pass "Spring123"
		
		Keep multiple machine name in TXT file to create user account newadmin on all those machines.

    .EXAMPLE
		Import-Csv .\list.csv | New-PSLocalAdmin -username newadmin -Pass "Spring123"
		
		Keep multiple machine name in CSV file to create user account newadmin on all those machines.The header name must be Computername.
		    
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
        [string[]]$computername = $env:COMPUTERNAME,
        [parameter()]
        [String]$Username = "dummy",
        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$pass
    )
    begin {

    }        
    process {
        foreach ($Computer in $ComputerName) { 
            if (test-connection $computer -count 1 -quiet:$true) {
                try {                                    
                    $server = [adsi]"WinNT://$Computer"
                    $user = $server.create('User', $Username)
                    $user.setpassword(($pass))
                    $user.setinfo()
                    ([ADSI]"WinNT://$computer/Administrators,group").add("WinNT://$computer/$Username,user")
                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        Status       = "$username has been added"                          
                    } 
                    $accountstatus = New-Object PSOBject -Property $info   
                    $accountstatus
                }                                    
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        Status       = "$ErrorMessage"                           
                    } 
                    $accountstatus = New-Object PSOBject -Property $info   
                    $accountstatus
                }    
            }
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer
                    Status       = "Computer is not reachable"                              
                } 
                $accountstatus = New-Object PSOBject -Property $info   
                $accountstatus
            }         

        }
    }    
    end {

    }
}