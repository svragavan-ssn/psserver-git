Function New-VdiProfile {
<#
	.SYNOPSIS
		Creates new profile for VDI.
	
	.DESCRIPTION
		Creates new profile and required subfolder for the user.If profile already exist then checks subfolder status.
	
	.PARAMETER Samaccount
		Samaccount name of the user.For WB user it should be WBUPI and  For IFC it should be shortname.
	
	.PARAMETER Upi
		Provide Nine digit UPI.If the length is not nine digit then the function will fail
	
	.EXAMPLE
		New-VdiProfile -Samaccountname wb463576
		
		To create new VDI Profile for WB user
	
	.EXAMPLE
		New-VdiProfile -Samaccountname vsubburaj
		
		To create new VDI Profile for IFC user

    .EXAMPLE
        New-VdiProfile -upi 000463576
        
        To create new VDI Profile using UPI.This is same for both IFC and WB users.
    .EXAMPLE
		Get-content .\list.txt | New-VdiProfile
		
		Keep multiple user(s) samaccount name in TXT file To create new VDI Profile.

    .EXAMPLE
        Import-Csv .\list.csv | New-VdiProfile
        
       Keep multiple user(s) samaccount name in CSV file To create new VDI Profile.
		    
	.NOTES
        Author: Vijayaragavan S
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License: 
#>    
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = "samaccount")]
        [validatenotnullorempty()]
        [string[]]$samaccount,
        [parameter(Mandatory = $True, ParameterSetName = "upi")]
        [ValidateLength(9, 9)]
        [string[]]$upi 
    )
    begin {
        $url = "\\wbgvdiprofile\VDI$"
        $windowsprofile = "WindowsProfile"
        $redirectedfolders = "RedirectedFolders"
        $NotesData = "NotesData"
        $wbdc1grp = [ADSI]"LDAP://CN=DC1_ED10_VDI_WB-Users,OU=XenDesktop,OU=Citrix,OU=Applications-Users-Groups,OU=_WB,DC=wb,DC=ad,DC=worldbank,DC=org"
        $wbdc2grp = [ADSI]"LDAP://CN=DC2_ED10_VDI_WB-Users,OU=XenDesktop,OU=Citrix,OU=Applications-Users-Groups,OU=_WB,DC=wb,DC=ad,DC=worldbank,DC=org"
        $ifcdc1grp = [ADSI]"LDAP://CN=DC1_ED10_VDI_IFC-Users,OU=XenDesktop,OU=Citrix,OU=Applications-Users-Groups,OU=_WB,DC=wb,DC=ad,DC=worldbank,DC=org"
        $ifcdc2grp = [ADSI]"LDAP://CN=DC2_ED10_VDI_IFC-Users,OU=XenDesktop,OU=Citrix,OU=Applications-Users-Groups,OU=_WB,DC=wb,DC=ad,DC=worldbank,DC=org"
        $wbdomain = "wb"
        $ifcdomain = "ifc"
        
        if (test-path -Path "C:\scripts") {

        }    
        else {
            New-Item -Path "C:\scripts" -ItemType Directory -ErrorAction Stop | Out-Null
        }
    }
    Process {
        try {
            <#The below code process based on SAMACCOUNT input#>
            if ($PSBoundParameters.ContainsKey("samaccount")) {
                foreach ($account in $samaccount) {
                    $wbfind = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(samaccountname=$account))"
                    $wbfind.searchroot = 'LDAP://wb.ad.worldbank.org'
                    $ifcfind = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(samaccountname=$account))"
                    $ifcfind.searchroot = 'LDAP://ifcad.ifc.org'
                    <# To find user in WB Domain #>
                    if ($wbfind.findone() -ne $null) {
                        $employeeid = $wbfind.findone().properties.employeeid[0]
                        <#Checking if the profile folder already exist #>
                        if (test-path -Path $url\$account) {
                            write-output "VDI Profile folder Exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            <#Checking if subfolders exist #>
                            if (test-path -Path $url\$account\$windowsprofile) {                        
                                write-output "Windowsprofile folder exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$windowsprofile -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Windowsprofile folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            if (test-path -Path $url\$account\$redirectedfolders) {  
                                write-output "Redirectedfolders folder exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$redirectedfolders -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Redirectedfolders folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            if (test-path -Path $url\$account\$NotesData) {
                                write-output "Notesdata folder exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$NotesData -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Notesdata folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                        }
                        <#Creating VDI profile folder#>
                        else { 
                            try {
                                Write-output "Creating VDI Profile for the user $account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                                New-Item -Path $url\$account -ItemType Directory -ErrorAction Stop | Out-Null
                                New-Item -Path $url\$account\$windowsprofile -ItemType Directory -ErrorAction Stop | out-null
                                New-Item -Path $url\$account\$redirectedfolders -ItemType Directory -ErrorAction Stop | out-null
                                New-Item -Path $url\$account\$NotesData -ItemType Directory -ErrorAction Stop | out-null
                                $acl = Get-Acl $url\$account
                                $acl.SetOwner([System.Security.Principal.NTAccount] "Administrators")
                                $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$Account", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")))
                                Set-Acl $url\$account $acl -ErrorAction Stop
                                Write-output "Created VDI Profile for the user $account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            catch {  
                                $ErrorMessage = $_.Exception.Message
                                write-output "Error when creating folder and setting ACL:$account,$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            } 
                        }
                        <#Checking last digit of employee id if it is odd or even number #>
                        try {
                            if ($employeeid[-1] % 2 -eq 0) {

                                $trans = New-Object -comObject "NameTranslate"
                                $objNT = $trans.GetType() 
                                $objNT.InvokeMember("Init", "InvokeMethod", $Null, $trans, (3, $Null))   
                                $objNT.InvokeMember("Set", "InvokeMethod", $Null, $trans, (3, "$wbdomain\$account"))
                                $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $trans, 1)
                                $user = [ADSI]"LDAP://$DN"
                                $wbdc2grp.add($user.ADsPath)
                                Write-output "Added the user $account to group DC2_ED10_VDI_WB-Users" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }    
                            else {
                                $trans = New-Object -comObject "NameTranslate"
                                $objNT = $trans.GetType() 
                                $objNT.InvokeMember("Init", "InvokeMethod", $Null, $trans, (3, $Null))   
                                $objNT.InvokeMember("Set", "InvokeMethod", $Null, $trans, (3, "$wbdomain\$account"))
                                $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $trans, 1)
                                $user = [ADSI]"LDAP://$DN"
                                $wbdc1grp.add($user.ADsPath)
                                Write-output "Added the user $account to group DC1_ED10_VDI_WB-Users" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            Write-output "Error when adding the user $account to the group:$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                        }                
                    }
                    # To find user in IFC Domain #
                    elseif ($ifcfind.findone() -ne $null) {
                        $employeeid = $ifcfind.findone().properties.employeeid[0]
                        if (test-path -Path $url\$account) {

                            write-output "VDI Profile folder Exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                           
                            if (test-path -Path $url\$account\$windowsprofile) {                        
                                write-output "Windowsprofile folder exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$windowsprofile -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Windowsprofile folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            if (test-path -Path $url\$account\$redirectedfolders) {  
                                write-output "Redirectedfolders folder exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$redirectedfolders -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Redirectedfolders folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            if (test-path -Path $url\$account\$NotesData) {
                                write-output "Notesdata folder exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$NotesData -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Notesdata folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                        }
                        else { 
                            try {
                                Write-output "Creating VDI Profile for the user $account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                                New-Item -Path $url\$account -ItemType Directory -ErrorAction Stop | Out-Null
                                New-Item -Path $url\$account\$windowsprofile -ItemType Directory -ErrorAction Stop | out-null
                                New-Item -Path $url\$account\$redirectedfolders -ItemType Directory -ErrorAction Stop| out-null
                                New-Item -Path $url\$account\$NotesData -ItemType Directory -ErrorAction Stop | out-null
                                $acl = Get-Acl $url\$account
                                $acl.SetOwner([System.Security.Principal.NTAccount] "Administrators")
                                $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$Account", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")))
                                Set-Acl $url\$account $acl -ErrorAction Stop
                                Write-output "Created VDI Profile for the user $account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            catch {  
                                $ErrorMessage = $_.Exception.Message
                                Write-output "Error when creating folder and setting ACL:$account,$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null 
                            } 
                        }

                        try {
                            if ($employeeid[-1] % 2 -eq 0) {

                                $trans = New-Object -comObject "NameTranslate"
                                $objNT = $trans.GetType() 
                                $objNT.InvokeMember("Init", "InvokeMethod", $Null, $trans, (3, $Null))   
                                $objNT.InvokeMember("Set", "InvokeMethod", $Null, $trans, (3, "$ifcdomain\$account"))
                                $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $trans, 1)
                                $user = [ADSI]"LDAP://$DN"
                                $ifcdc2grp.add($user.ADsPath)
                                Write-output "Added the user $account to group DC2_ED10_VDI_IFC-Users" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null 
                            }    
                            else {
                                $trans = New-Object -comObject "NameTranslate"
                                $objNT = $trans.GetType() 
                                $objNT.InvokeMember("Init", "InvokeMethod", $Null, $trans, (3, $Null))   
                                $objNT.InvokeMember("Set", "InvokeMethod", $Null, $trans, (3, "$ifcdomain\$account"))
                                $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $trans, 1)
                                $user = [ADSI]"LDAP://$DN"
                                $ifcdc1grp.add($user.ADsPath)
                                Write-output "Added the user $account to group DC1_ED10_VDI_IFC-Users" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null 
                            }
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            Write-output "Error when adding the user $account in group:$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null                          
                        }                
                    }
                    else {
                        Write-output "User account $account doesn't exist in Directory." | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                    }    
                }    
            }
            <#The below code process based on UPI input#>
            if ($PSBoundParameters.ContainsKey("upi")) {
                foreach ($userupi in $upi) {
                    $wbfind = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(cn=$userupi))"
                    $wbfind.searchroot = 'LDAP://wb.ad.worldbank.org'
                    $ifcfind = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(cn=$userupi))"
                    $ifcfind.searchroot = 'LDAP://ifcad.ifc.org'
                    <# To find user in WB Domain #>
                    if ($wbfind.findone() -ne $null) {
                        $account = $wbfind.findone().properties.samaccountname[0]
                        $employeeid = $wbfind.findone().properties.employeeid[0]

                        <#Checking if the profile folder already exist #>
                        if (test-path -Path $url\$account) {
                            write-output "VDI Profile folder Exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            
                            <#Checking if subfolders exist #>
                            if (test-path -Path $url\$account\$windowsprofile) {                                   
                                write-output "Windowsprofile folder exist:$account"  | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$windowsprofile -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Windowsprofile folder:$account"  | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            if (test-path -Path $url\$account\$redirectedfolders) {                                    
                                write-output "Redirectedfolders folder exist:$account " | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$redirectedfolders -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Redirectedfolder folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            if (test-path -Path $url\$account\$NotesData) {     
                                write-output "NotesData folder exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$NotesData -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Notesdata folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                        }

                        else {
                            try {

                                Write-output "Creating VDI Profile for the user $account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                                New-Item -Path $url\$account -ItemType Directory -ErrorAction Stop | Out-Null
                                New-Item -Path $url\$account\$windowsprofile -ItemType Directory -ErrorAction Stop | out-null
                                New-Item -Path $url\$account\$redirectedfolders -ItemType Directory -ErrorAction Stop | out-null
                                New-Item -Path $url\$account\$NotesData -ItemType Directory -ErrorAction Stop | out-null
                                $acl = Get-Acl $url\$account
                                $acl.SetOwner([System.Security.Principal.NTAccount] "Administrators")
                                $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$Account", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")))
                                Set-Acl "$url\$account" $acl -ErrorAction Stop
                                write-output "Created profile for the user $account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null

                            }
                            catch {
                                $ErrorMessage = $_.Exception.Message
                                Write-output "Error when creating folder and setting ACL:$account,$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null 
                            }  
                            
                        }

                        try {
                            if ($employeeid[-1] % 2 -eq 0) {
                                $trans = New-Object -comObject "NameTranslate"
                                $objNT = $trans.GetType() 
                                $objNT.InvokeMember("Init", "InvokeMethod", $Null, $trans, (3, $Null))   
                                $objNT.InvokeMember("Set", "InvokeMethod", $Null, $trans, (3, "$wbdomain\$account"))
                                $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $trans, 1)
                                $user = [ADSI]"LDAP://$DN"
                                $wbdc2grp.add($user.ADsPath)
                                Write-output "Added the user $account to group DC2_ED10_VDI_WB-Users" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null 
                            }
                                
                            else {
                                    
                                $trans = New-Object -comObject "NameTranslate"
                                $objNT = $trans.GetType() 
                                $objNT.InvokeMember("Init", "InvokeMethod", $Null, $trans, (3, $Null))   
                                $objNT.InvokeMember("Set", "InvokeMethod", $Null, $trans, (3, "$wbdomain\$account"))
                                $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $trans, 1)
                                $user = [ADSI]"LDAP://$DN"
                                $wbdc1grp.add($user.ADsPath) 
                                Write-output "Added the user $account to group DC1_ED10_VDI_WB-Users" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null  
                            }    
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            Write-output "Error when adding the user $account in group:$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null         
                        }
                                
                    }
                    <# To find user in WB Domain #>
                    elseif ($ifcfind.findone() -ne $null) {
                        $account = $ifcfind.findone().properties.samaccountname[0]
                        $employeeid = $ifcfind.findone().properties.employeeid[0]
                        if (test-path -Path $url\$account) {
                            write-output "Profile folder Exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null  
                            if (test-path -Path $url\$account\$windowsprofile) {                                   
                                write-output "Windowsprofile folder exist:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$windowsprofile -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Windowsprofile folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            if (test-path -Path $url\$account\$redirectedfolders) {                                    
                                write-output "Redirectedfolders folder exist:$account " | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$redirectedfolders -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Redirectedfolder folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            if (test-path -Path $url\$account\$NotesData) {     
                                write-output "NotesData folder exist:$account"  | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            else {
                                New-Item -Path $url\$account\$NotesData -ItemType Directory -ErrorAction Stop | out-null
                                write-output "Created Notesdata folder:$account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            
                        }
                        else {
                            try {
                                Write-output "Creating VDI Profile for the user $account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null  
                                New-Item -Path $url\$account -ItemType Directory -ErrorAction Stop | Out-Null
                                New-Item -Path $url\$account\$windowsprofile -ItemType Directory -ErrorAction Stop | out-null
                                New-Item -Path $url\$account\$redirectedfolders -ItemType Directory -ErrorAction Stop | out-null
                                New-Item -Path $url\$account\$NotesData -ItemType Directory -ErrorAction Stop | out-null
                                $acl = Get-Acl $url\$account
                                $acl.SetOwner([System.Security.Principal.NTAccount] "Administrators")
                                $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$Account", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")))
                                Set-Acl "$url\$account" $acl -ErrorAction Stop
                                write-output "Created profile for the user $account" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                            }
                            catch {
                                $ErrorMessage = $_.Exception.Message
                                Write-output "Error when creating folder and setting ACL:$account,$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null  
                                
                            } 
                            
                        }

                        try {
                            if ($employeeid[-1] % 2 -eq 0) {

                                $trans = New-Object -comObject "NameTranslate"
                                $objNT = $trans.GetType() 
                                $objNT.InvokeMember("Init", "InvokeMethod", $Null, $trans, (3, $Null))   
                                $objNT.InvokeMember("Set", "InvokeMethod", $Null, $trans, (3, "$ifcdomain\$account"))
                                $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $trans, 1)
                                $user = [ADSI]"LDAP://$DN"
                                $ifcdc2grp.add($user.ADsPath)
                                Write-output "Added the user $account to group DC2_ED10_VDI_IFC-Users" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null 
                            }
                            else {
                                $trans = New-Object -comObject "NameTranslate"
                                $objNT = $trans.GetType() 
                                $objNT.InvokeMember("Init", "InvokeMethod", $Null, $trans, (3, $Null))   
                                $objNT.InvokeMember("Set", "InvokeMethod", $Null, $trans, (3, "$ifcdomain\$account"))
                                $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $trans, 1)
                                $user = [ADSI]"LDAP://$DN"
                                $ifcdc1grp.add($user.ADsPath)
                                Write-output "Added the user $account to group DC1_ED10_VDI_IFC-Users" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null 
                            }
                        }  
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            Write-output "Error when adding the user $account in group:$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null         
                        }
                    }
                    else {
                        Write-output "User account $upi doesn't exist in Directory." | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
                    }              
                }            
            }
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-output "$ErrorMessage" | out-file -Encoding Ascii -append "C:\scripts\vdi-profile.log" | out-null
        }    
                                                           
    }
    End {
       
    }
}