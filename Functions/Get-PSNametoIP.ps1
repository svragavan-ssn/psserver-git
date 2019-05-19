Function Get-PSNametoIP {
<#
	.SYNOPSIS
		Gets IP Address of machine.
	
	.DESCRIPTION
		This is similar to nslookup.You can provide name that resolves to IP Address.
	
	.PARAMETER ComputerName
		The machine name that needs to be resolved.The value is mandatory
	
	.EXAMPLE
		Get-PSNametoIP -ComputerName SRVTST01,SRVTST02
		
	    Gets IP address of multiple computers.You can specify multiple Name's separatig them by comma.
	
    .EXAMPLE
		Get-content .\list.txt | Get-PSNametoIP
        
        Keep multiple name in TXT file to resolve more than one.
    
    .EXAMPLE
		Import-Csv .\list.csv | Get-PSNametoIP
        
        Keep multiple name in CSV file to resolve more than one.The header name must be Computername.
	    
	.NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License:  
#>
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [Validatenotnullorempty()]
        [string[]]$ComputerName 
    )                  
    Begin {
      
    }
    Process {
        foreach ($machine in $ComputerName) {
            try {
                $result = [System.Net.Dns]::gethostentry("$machine")
                $info = [ordered]@{       
                    Name = $machine
                    IP   = $Result.AddressList.IPAddressToString
                    Status = "Success"
                }        
                $hostname = New-Object PSOBject -Property $info 
                $hostname
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                $info = [ordered]@{       
                    Name = $machine
                    IP   = "NA"
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