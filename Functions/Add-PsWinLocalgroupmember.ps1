Function Add-PsWinLocalgroupmember {
<#
	.SYNOPSIS
		Adds a user or group as Local Administrator.
	
	.DESCRIPTION
		Adds a user or group as Local Administrator in Local machine or Remote machine.
	
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
		Add-PSLocalAdmin -ComputerName SRVTST01 -LocalUser admin
		
        Adds local user account admin in Local Administrators group on machine SRVTST01.
        
	.EXAMPLE
		Add-PSLocalAdmin -ComputerName SRVTST01 -DomainGroup "TST-Admin-Group" -Domain tst.local
		
		Adds Domain Group TST-Admin-Group from domain tst.local in Local Administrators group on computer SRVTST01.The group must exist in tst.local domain.If domain is not specified then logged on user's domain will be taken.

    .EXAMPLE
		Add-PSLocalAdmin -ComputerName SRVTST01 -Domainuser "Serveradmin" -Domain tst.local
        
        Adds Domain User Serveradmin from tst.local domain in Local Administrators group on computer SRVTST01.The user must exist in tst.local domain.If the domain is not specified then logged on user's domain will be taken.
		    
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
        [parameter(ParameterSetName = "Localgroup")]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory = $True, ParameterSetName = "DomainUser")]
        [ValidateNotNullOrEmpty()]
        [String]$DomainUser,
        [parameter(Mandatory = $True, ParameterSetName = "DomainGroup")]
        [ValidateNotNullOrEmpty()]
        [String]$DomainGroup,
        [parameter(ParameterSetName = "DomainUser")]
        [parameter(ParameterSetName = "DomainGroup")]
        [ValidateNotNullOrEmpty()]
        [String]$Domain = $env:USERDNSDOMAIN,
        [parameter(Mandatory = $True, ParameterSetName = "LocalUser")]
        [ValidateNotNullOrEmpty()]
        [String]$LocalUser = "Dummy",
        [parameter(Mandatory = $True, ParameterSetName = "Localgroup")]
        [ValidateNotNullOrEmpty()]
        [String]$Localgroup = "Administartor"
    )

    begin {

    }        

    process {

        foreach ($Computer in $ComputerName) { 

            if (test-connection $computer -count 1 -quiet:$true) {

                try {                                    

                    if ($PsCmdlet.ParameterSetName -eq "DomainUser") {
                        $find = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(samaccountname=$DomainUser))"
                        $find.SearchRoot = "LDAP://$domain"
                        if ($find.findone() -ne $null) {
                            $username = $find.findone().properties.samaccountname[0]
                            $account = 'WinNT://', "$domain", '/', $username -join ''
                            ([ADSI]"WinNT://$computer/$localgroup,group").add($account)
                            $info = [ordered]@{ 
                                ComputerName = $Computer                               
                                Status       = "$Username Added"
                            }                         
                            $Accounttatus = New-Object PSOBject -Property $info   
                            $Accounttatus
                        }
                        else {
                            $info = [ordered]@{ 
                                ComputerName = $Computer
                                Status       = "$Username Doesn't Exist in Directory" 
                            }                         
                            $Accounttatus = New-Object PSOBject -Property $info   
                            $Accounttatus
                        }                                
                    }        
                    if ($PsCmdlet.ParameterSetName -eq "DomainGroup") { 
                        $find = [adsisearcher]"(&(objectClass=group)(samaccountname=$domaingroup))"
                        $find.SearchRoot = "LDAP://$domain"
                        if ($find.findone() -ne $null) {
                            $groupname = $find.findone().properties.samaccountname[0]
                            $account = 'WinNT://', "$domain", '/', $groupname -join ''
                            ([ADSI]"WinNT://$computer/$localgroup,group").add($account)
                            $info = [ordered]@{ 
                                ComputerName = $Computer                               
                                Status       = "$groupname Added"
                            }                         
                            $Accounttatus = New-Object PSOBject -Property $info   
                            $Accounttatus
                        }
                        else {
                            $info = [ordered]@{ 
                                ComputerName = $Computer                             
                                Status       = "$groupname Doesn't Exist in Directory"  
                            }                         
                            $Accounttatus = New-Object PSOBject -Property $info   
                            $Accounttatus
                        }
                    }
                    if ($PsCmdlet.ParameterSetName -eq "localUser") {
                        $username = [adsi]"WinNT://$Computer/$LocalUser,user"
                        $account = $username.name
                        if ($account -ne $null) {
                            ([ADSI]"WinNT://$computer/$localgroup,group").add("WinNT://$computer/$account,user")
                            $info = [ordered]@{ 
                                ComputerName = $Computer                               
                                Status       = "$account Added"
                            }                         
                            $Accounttatus = New-Object PSOBject -Property $info   
                            $Accounttatus
                        } 
                        else {
                            $info = [ordered]@{ 
                                ComputerName = $Computer                            
                                Status       = "$account Doesn't Exist in Directory"  
                            }                         
                            $Accounttatus = New-Object PSOBject -Property $info   
                            $Accounttatus
                        }                                                                             
                    }            
                }                                    
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName = $Computer   
                        Status       = "$ErrorMessage"
                    }                         
                    $Accounttatus = New-Object PSOBject -Property $info   
                    $Accounttatus
                }    
            }
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer                            
                    Status       = "Computer is Not Reachable"
                }                         
                $Accounttatus = New-Object PSOBject -Property $info   
                $Accounttatus
            }         
        }
    }    
    end {

    }
}