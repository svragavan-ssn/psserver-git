Function Get-PSNetwork {
<#
	.SYNOPSIS
		Gets network information.
	
	.DESCRIPTION
		Gets network information in Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine name to get the information. Defaults to localhost.
	
	.EXAMPLE
		Get-PSNetwork
		
	    Gets IP,subnet,gateway and DNS information of local machine.
	
	.EXAMPLE
		Get-PSNetwork -computername SRVTST01,SRVTST02
		
		Gets IP,subnet,gateway and DNS information of machine SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt | Get-PSNetwork
        
        Keep multiple machine name in TXT file to get IP,subnet,gateway and DNS information.
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSNetwork
        
        Keep multiple machine name in CSV file to get IP,subnet,gateway and DNS information.The header name must be Computername.
	    
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
        [string[]]$computername = $env:COMPUTERNAME
    )
    Begin {

    }        
    Process {
        foreach ($Computer in $ComputerName) { 
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {
                    
                    $intindex = get-wmiobject win32_networkadapter -computername $computer -filter "netconnectionstatus = 2" | select-object -expandproperty InterfaceIndex
                    
                    foreach ($interface in $intindex) {
                    
                        $nic = Get-WmiObject Win32_networkadapterconfiguration -ComputerName $Computer -ErrorAction Stop | where-object {$_.interfaceindex -eq $interface}
                        $label=get-wmiobject win32_networkadapter -ComputerName $Computer -filter "interfaceindex=$interface" | select-object -expandproperty Netconnectionid
                        $info = [ordered]@{ 
                            ComputerName   = $Computer
                            NetworkLabel = $label                                                 
                            IPAddress      = [string]$nic.ipaddress
                            IPSubnet       = [string]$nic.IPSubnet
                            Defaultgateway = [string]$nic.DefaultIPGateway
                            Dnsserver      = [string]$nic.dnsserversearchorder
                            Dnssuffix      = [string]$nic.DNSDomainSuffixSearchOrder
                            Status         = "Success"    
                        }
                        $networkinformation = New-Object PSOBject -Property $info   
                        $networkinformation 
                    }                                              
                }                                    
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName   = $Computer
                        IPAddress      = ""
                        IPSubnet       = ""
                        Defaultgateway = ""
                        Dnsserver      = ""
                        Dnssuffix      = ""
                        Status         = "$ErrorMessage"                          
                    }                      
                    $networkinformation = New-Object PSOBject -Property $info   
                    $networkinformation  
                }    
            }
            else {
                $info = [ordered]@{ 
                    ComputerName   = $Computer
                    IPAddress      = ""
                    IPSubnet       = ""
                    Defaultgateway = ""
                    Dnsserver      = ""
                    Dnssuffix      = ""
                    Status         = "Computer is not reachable" 
                }                       
                $networkinformation = New-Object PSOBject -Property $info   
                $networkinformation
            }   
        }
    }
    End {

    }    
}