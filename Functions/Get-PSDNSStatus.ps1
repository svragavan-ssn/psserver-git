Function Get-PSDNSStatus {
<#
	.SYNOPSIS
		Checks if DNS record exist for set of FQDN's
	
	.DESCRIPTION
		Checks if DNS record exist for set of FQDN's for the given machine.
	
	.PARAMETER ComputerName
		The machine name to get the information.Defaults to localhost.
	
    .EXAMPLE
		Get-PSDNSStatus 
		
		Gets DNS record information of local machine.

    .EXAMPLE
		Get-PSDNSStatus  -computername SRVTST01,SRVTST02
		
		Gets DNS record information of machine SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt | Get-PSUptime
        
        Keep multiple machine name in TXT file to get their information.
    
    .EXAMPLE
		Import-Csv .\list.csv | Get-PSUptime
        
        Keep multiple machine name in CSV file to get their information.The header name must be Computername.
	    
	.NOTES
        Author: Vijayaragavan S
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan 
		License:  
#>        
    Param(
        [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )   
    begin {
        
    }
    process {
    
        foreach ($machine in $ComputerName) {
            try {
                $wbrootrecord = "No"
                $ifcrootrecord = "No"
                $wbrecord = "No"
                $trerecord = "No"
                $egrecord = "No"
                $ifcrecord = "No"
                $tstwbrecord = "No"
                $tsttrerecord = "No"
                $tstegrecord = "No"
                $tstifcrecord = "No"
                $devwbrecord = "No"
                $devtrerecord = "No"
                $devegrecord = "No"
                $devifcrecord = "No"
                $zdrecord = "No"
                $extrecord = "No"
                $awrecord = "No"
                $status = "NA"
                
                if (test-connection "$machine.worldbank.org" -Quiet:$true -Count 2) {
                    $wbrootrecord = "Yes"
                }
                if (test-connection "$machine.ifc.org" -Quiet:$true -Count 2) {
                    $ifcrootrecord = "Yes"
                }
                if (test-connection "$machine.wb.ad.worldbank.org" -Quiet:$true -Count 2) {
                    $wbrecord = "Yes"

                    $wbfind = [adsisearcher]"(&(objectClass=computer)(cn=$machine))"
                    $wbfind.searchroot = 'LDAP://wb.ad.worldbank.org'
                    if ($wbfind.findone() -ne $null) {
                        $enabled = $wbfind.findone().properties.useraccountcontrol[0]
                        if ($enabled -eq "4098") {

                            $status = "WB Disabled"
                        }
                        elseif ($enabled -eq "4096") {
                            $status = "WB Enabled"
                        }
                        else {

                            $status = "NA"
                        }                        
                    }   
                } 
                if (test-connection "$machine.ifcad.ifc.org" -Quiet:$true -Count 2) {
                    $ifcrecord = "Yes"

                    $ifcfind = [adsisearcher]"(&(objectClass=computer)(cn=$machine))"
                    $ifcfind.searchroot = 'LDAP://ifcad.ifc.org'
                    if ($ifcfind.findone() -ne $null) {
                        $enabled = $ifcfind.findone().properties.useraccountcontrol[0]
                        if ($enabled -eq "4098") {

                            $status = "IFC Disabled"
                        }
                        elseif ($enabled -eq "4096") {
                            $status = "IFC Enabled"
                        }
                        else {

                            $status = "NA"
                        }                        
                    }   
                }
                if (test-connection "$machine.tre.ad.worldbank.org" -Quiet:$true -Count 2) {
                    $trerecord = "Yes"
                    $trefind = [adsisearcher]"(&(objectClass=computer)(cn=$machine))"
                    $trefind.searchroot = 'LDAP://tre.ad.worldbank.org'
                    if ($trefind.findone() -ne $null) {
                        $enabled = $trefind.findone().properties.useraccountcontrol[0]
                        if ($enabled -eq "4098") {

                            $status = "TRE Disabled"
                        }
                        elseif ($enabled -eq "4096") {
                            $status = "TRE Enabled"
                        }

                        else {

                            $status = "NA"
                        }
                        
                    }   
                } 
                if (test-connection "$machine.eg.ad.worldbank.org" -Quiet:$true -Count 2) {
                    $egrecord = "Yes"
                    $egfind = [adsisearcher]"(&(objectClass=computer)(cn=$machine))"
                    $egfind.searchroot = 'LDAP://eg.ad.worldbank.org'
                    if ($egfind.findone() -ne $null) {
                        $enabled = $egfind.findone().properties.useraccountcontrol[0]
                        if ($enabled -eq "4098") {

                            $status = "EG Disabled"
                        }
                        elseif ($enabled -eq "4096") {
                            $status = "EG Enabled"
                        }

                        else {

                            $status = "NA"
                        }
                        
                    }   
                }
                if (test-connection "$machine.tstwb.tstad.worldbank.org" -Quiet:$true -Count 2) {
                    $tstwbrecord = "Yes"
                }
                if (test-connection "$machine.devwb.devad.worldbank.org" -Quiet:$true -Count 2) {
                    $devwbrecord = "Yes"
                }
                if (test-connection "$machine.zd.worldbank.org" -Quiet:$true -Count 2) {
                    $zdrecord = "Yes"
                }
                if (test-connection "$machine.wbgext.worldbank.org" -Quiet:$true -Count 2) {
                    $extrecord = "Yes"
                }
                if (test-connection "$machine.aw.worldbank.org" -Quiet:$true -Count 2) {
                    $awrecord = "Yes"
                }
                if (test-connection "$machine.tsttre.tstad.worldbank.org" -Quiet:$true -Count 2) {
                    $tsttrerecord = "Yes"
                }
                if (test-connection "$machine.tsteg.tstad.worldbank.org" -Quiet:$true -Count 2) {
                    $tstegrecord = "Yes"
                }
                if (test-connection "$machine.tstifcad.ifc.org" -Quiet:$true -Count 2) {
                    $tstifcrecord = "Yes"
                }
                if (test-connection "$machine.devtre.devad.worldbank.org" -Quiet:$true -Count 2) {
                    $devtrerecord = "Yes"
                }
                if (test-connection "$machine.deveg.devad.worldbank.org" -Quiet:$true -Count 2) {
                    $devegrecord = "Yes"
                }
                if (test-connection "$machine.devifcad.devifc.org" -Quiet:$true -Count 2) {
                    $devifcrecord = "Yes"
                }

                $info = [ordered]@{       
                    Name    = $machine
                    root    = $wbrootrecord 
                    rootifc = $ifcrootrecord 
                    wb      = $wbrecord 
                    tre     = $trerecord
                    eg      = $egrecord 
                    ifc     = $ifcrecord 
                    tstwb   = $tstwbrecord
                    tsttre  = $tsttrerecord
                    tsteg   = $tstegrecord 
                    tstifc  = $tstifcrecord
                    devwb   = $devwbrecord 
                    devtre  = $devtrerecord
                    deveg   = $devegrecord 
                    devifc  = $devifcrecord 
                    zd      = $zdrecord     
                    ext     = $extrecord     
                    aw      = $awrecord      
                    Enabled = $status        
                }        
                $hostname = New-Object PSOBject -Property $info 
                $hostname
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Warning "$machine,$ErrorMessage" 
            }         
        }
    }
    end {

    }
}