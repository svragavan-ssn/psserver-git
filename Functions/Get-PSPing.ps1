Function Get-PSPing {
<#
	.SYNOPSIS
		Invokes ICMP request to find the computer's connection state.
	
	.DESCRIPTION
		This function is simillar to Ping command.Invokes ICMP requests to find the computer's connection state.
	
	.PARAMETER ComputerName
		The target machine name to check connection state.The value is mandatory
	
	.EXAMPLE
		Get-PSPing -computername SRVTST01,SRVTST02
		
		Checks availability of machine SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt | Get-PSPing
        
        Keep multiple machine name in TXT file to get their availability.
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSPing
        
        Keep multiple machine name in CSV file to get their availability.The header name must be Computername.
	    
	.NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License:  
#>     
    [cmdletbinding()]
    param (    
        [parameter(Mandatory = $true, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [Validatenotnullorempty()]
        [string[]]$ComputerName 
    )
    Begin {

    }        
    Process {
        foreach ($Computer in $ComputerName) { 
            if (Test-connection $computer -count 2 -quiet:$true) {     
                $info = [ordered]@{ 
                    ComputerName = $Computer 
                    Status       = "UP"                              
                }                         
                $pingstatus = New-Object PSOBject -Property $info   
                $pingstatus    
            }
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer 
                    Status       = "Down"                              
                } 
                $pingstatus = New-Object PSOBject -Property $info   
                $pingstatus
            }   
        }
    }
    End {

    }    
}