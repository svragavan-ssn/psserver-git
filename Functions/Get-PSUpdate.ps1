Function Get-PSUpdate {
<#
	.SYNOPSIS
		Gets installed MS updates
	
	.DESCRIPTION
		Gets installed update information from local machine or remote machine.The function is based on .NET update searcher method.The output may not be reliable.The method gets information from softwaredistribution folder.If the folder deleted or renamed then we will not get desired output.
	
	.PARAMETER ComputerName
		The target machine name to get the information.Defaults to localhost.
	
    .EXAMPLE
		Get-PSUpdate
		
		Gets the information of local machine.

    .EXAMPLE
		Get-PSUpdate -computername SRVTST01,SRVTST02
		
		Gets the information from SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt |Get-PSUpdate
        
        Keep multiple machine name in TXT file to get their information.
    
    .EXAMPLE
		Import-Csv .\list.csv | Get-PSUpdate
        
        Keep multiple machine name in CSV file to get their information.The header name must be Computername.
	    
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
        [string[]]$computername = $env:COMPUTERNAME,    
        [parameter()]
        [datetime]$date=(get-date)    
    )
    Begin {

    }
    Process {
        Foreach ($computer in $computername) {
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {
                    $session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session", $Computer))
                    $criteria = "IsInstalled=0 and IsHidden=0"
                    $search = $session.CreateUpdateSearcher().Search($criteria).Updates
                    $total = $search.GetTotalHistoryCount() 

                    if ($total -ge 1) {
                        $updates = $search.QueryHistory(0, $total)
                        foreach ($Update in $updates) {
                            if ($Update.operation -eq 1 -and $Update.resultcode -eq 2) {
                                $info = [ordered] @{
                                    ComputerName      = $computer 
                                    UpdateDate        = $Update.date
                                    KB                = [regex]::match($Update.Title, 'KB(\d+)')
                                    UpdateTitle       = $Update.title
                                    UpdateDescription = $Update.Description
                                    Status            = "Success" 
                                } 
                                $updateinformation = New-Object PSOBject -Property $info
                                $updateinformation
                            }
                        }
                    }
                    else {
                        $info = [ordered] @{
                            ComputerName      = $computer
                            UpdateDate        = ""
                            KB                = ""
                            UpdateTitle       = ""
                            UpdateDescription = ""
                            Status            = "No update Installed"
                        }    
                        $updateinformation = New-Object PSOBject -Property $info
                        $updateinformation
                    }       
                } 
                catch {
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered] @{
                        ComputerName      = $computer
                        UpdateDate        = ""
                        KB                = ""
                        UpdateTitle       = ""
                        UpdateDescription = ""
                        Status            = "$ErrorMessage"
                    }    
                    $updateinformation = New-Object PSOBject -Property $info
                    $updateinformation
                }                              
            }
            else {
                $info = [ordered] @{
                    ComputerName      = $computer
                    UpdateDate        = ""
                    KB                = ""
                    UpdateTitle       = ""
                    UpdateDescription = ""
                    Status            = "Computer is not reachable"
                }    
                $updateinformation = New-Object PSOBject -Property $info
                $updateinformation
            }  
        }
    }

    End {

    }
}