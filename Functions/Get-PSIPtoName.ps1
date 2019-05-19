Function Get-PSIPtoName {
<#
	.SYNOPSIS
		Gets machine name by providing IP Address.
	
	.DESCRIPTION
		This is similar to nslookup.You can provide IP address that resolves to machine name.
	
	.PARAMETER IP
		The IP address that needs to be resolved.The value is mandatory
	
	.EXAMPLE
		Get-PSIPtoName -IP 10.10.10.1,10.10.10.2
		
	    This example shows to get hostname for multiple IP addresses.You can provide multiple IP's by comma.
	
	.EXAMPLE
		"10.10.10.1" | Get-PSIPtoName
		
		This example shows to pass the IP address value through pipeline.

    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSIPtoName
        
        Keep multiple IP's in CSV file to resolve more than one.The header name must be IP.
    
    .EXAMPLE
		Get-Content .\list.txt | Get-PSIPtoName
        
        Keep multiple IP's in TXT file to resolve more than one.
	    
	.NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License:  
#>    
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$IP
    )                  
    Begin {
      
    }
    Process {
        foreach ($address in $IP) {
            try {
                $result = [System.Net.Dns]::gethostentry($address)
                $info = [ordered]@{       
                    Name   = [string]$Result.HostName
                    IP     = $address
                    Status = "Success"
                }        
                $hostname = New-Object PSOBject -Property $info 
                $hostname
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                $info = [ordered]@{       
                    Name   = "NA"
                    IP     = $address
                    Status = "$ErrorMessage"
                }        
                $hostname = New-Object PSOBject -Property $info 
                $hostname 
            }         
        }
    }
    End {
    }
}