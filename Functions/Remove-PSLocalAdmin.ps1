Function Remove-PSLocalAdmin {
<#
	.SYNOPSIS
		Adds a user or group as Administrator.
	
	.DESCRIPTION
		Adds a user or group as Administrator in Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine name to add the account. Defaults to localhost.
	
	.PARAMETER Domain
		Specify the Domain the account is located. Defaults to logged on users.
	
	.PARAMETER DomainGroup
		Group name that needs to be added to Local Administrators group.The group must exist in the Domain.
	
	.PARAMETER DomainUser
		User name that needs to be added to Local Administrators group.The user must exist in the Domain.
	
	.PARAMETER LocalUser
		User name that needs to be added to Local Administrators group.The user must exist in local machine.
	
	.EXAMPLE
		Remove-PSLocalAdmin -ComputerName SRVTST01 -LocalUser admin
		
		Removes local user account admin from Local Administrators group and deletes the account from machine SRVTST01.
	
	.EXAMPLE
		Remove-PSLocalAdmin -ComputerName SRVTST01 -DomainGroup "TST-Admin-Group" -Domain tst.local
		
		Removes Domain Group TST-Admin-Group from domain tst.local in Local Administrators group on computer SRVTST01.The group must exist in tst.local domain.If domain is not specified then logged on user's domain will be taken.

    .EXAMPLE
		Remove-PSLocalAdmin -ComputerName SRVTST01 -Domainuser "Serveradmin" -Domain tst.local
        
        Removes Domain User Serveradmin from tst.local domain in Local Administrators group on computer SRVTST01.The user must exist in tst.local domain.If the domain is not specified then logged on user's domain will be taken
		    
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
        [parameter(ParameterSetName = "DomainUser")]
        [parameter(ParameterSetName = "DomainGroup")]
        [parameter(ParameterSetName = "LocalUser")]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory = $true, ParameterSetName = "DomainUser")]
        [Validatenotnullorempty()]
        [String]$DomainUser,
        [parameter(Mandatory = $true, ParameterSetName = "DomainGroup")]
        [Validatenotnullorempty()]
        [String]$DomainGroup,
        [parameter(ParameterSetName = "DomainUser")]
        [parameter(ParameterSetName = "DomainGroup")]
        [ValidateNotNullOrEmpty()]
        [String]$Domain = $env:userdomain,
        [parameter(Mandatory = $true, ParameterSetName = "LocalUser")]
        [String]$LocalUser = "dummy"
    )

    Begin {
    }        
    Process {
        Foreach ($Computer in $ComputerName) { 
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {                                    
                    if ($PSBoundParameters.ContainsKey("DomainUser")) {
                        $find = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(samaccountname=$DomainUser))"
                        $find.SearchRoot = "LDAP://$domain"
                        if ($find.findone() -ne $null) {
                            $username = $find.findone().properties.samaccountname[0]
                            $account = 'WinNT://', "$domain", '/', $username -join ''                                                        
                            ([ADSI]"WinNT://$computer/Administrators,group").remove($account)                            
                            $info = [ordered]@{ 
                                ComputerName = $Computer
                                Status       = "$username has been removed"                              
                            } 
                            $accountstatus = New-Object PSOBject -Property $info   
                            $accountstatus
                        }
                        else {
                            $info = [ordered]@{ 
                                ComputerName = $Computer
                                Status       = "$domainuser Doesn't Exist in Directory"                              
                            } 
                            $accountstatus = New-Object PSOBject -Property $info   
                            $accountstatus
                        }                                
                    }        
                    if ($PSBoundParameters.ContainsKey("DomainGroup")) { 
                        $find = [adsisearcher]"(&(objectClass=group)(samaccountname=$domaingroup))"
                        $find.SearchRoot = "LDAP://$domain"
                        if ($find.findone() -ne $null) {
                            $groupname = $find.findone().properties.samaccountname[0]
                            $account = 'WinNT://', "$domain", '/', $groupname -join ''
                            ([ADSI]"WinNT://$computer/Administrators,group").remove($account)
                            $info = [ordered]@{ 
                                ComputerName = $Computer
                                Status       = "$groupname has been removed"                              
                            } 
                            $accountstatus = New-Object PSOBject -Property $info   
                            $accountstatus
                        }
                        else {
                            $info = [ordered]@{ 
                                ComputerName = $Computer
                                Status       = "$domaingroup doesn't exist in Directory"                              
                            } 
                            $accountstatus = New-Object PSOBject -Property $info   
                            $accountstatus
                        }
                    }
                    if ($PSBoundParameters.ContainsKey("localUser")) {
                        $server = [adsi]"WinNT://$Computer"
                        $username = [adsi]"WinNT://$Computer/$LocalUser,user"
                        $account = $username.name
                        if ($account -ne $null) {
                            $server.Delete('user', "$account")
                            $info = [ordered]@{ 
                                ComputerName = $Computer
                                Status       = "$account has been deleted"                             
                            } 
                            $accountstatus = New-Object PSOBject -Property $info   
                            $accountstatus
                        } 
                        else {
                            $info = [ordered]@{ 
                                ComputerName = $Computer
                                Status       = "$localuser Doesn't Exist in Localmachine"                              
                            } 
                            $accountstatus = New-Object PSOBject -Property $info   
                            $accountstatus
                        }                                                                             
                    }                                                   
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