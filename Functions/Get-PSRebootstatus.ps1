Function Get-PSRebootStatus {
<#
	.SYNOPSIS
		Gets reboot information of a machine.
	
	.DESCRIPTION
		Gets date,reason,process,type and username of reboot information from Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine name to get the information. Defaults to localhost.
	
	.EXAMPLE
		Get-PSRebootStatus
		
	    Gets date,reason,process,type and username of reboot information from of local machine.
	
	.EXAMPLE
		Get-PSRebootStatus -computername SRVTST01,SRVTST02
		
		Gets date,reason,process,type and username of reboot information from machine SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt | Get-PSRebootStatus
        
        Keep multiple machine name in TXT file to get date,reason,process,type and username of reboot information.
    
    .EXAMPLE
		Import-Csv  .\list.csv | Get-PSRebootStatus
        
        Keep multiple machine name in CSV file to get date,reason,process,type and username of reboot information.
	    
	.NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License:  
#>     
    [cmdletbinding()]
    param (    
        [parameter(Mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True,position=0)]
        [string[]]$computername = $env:COMPUTERNAME,
        [parameter()]
        [int]$count=5
    )
    Begin {

    }        
    Process {
        foreach ($Computer in $ComputerName) { 
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {
                    $Events = Get-WinEvent -computername $computer -FilterHashtable @{logname = 'System'; ID = 1074; } -Maxevents $count
                    if($Events){
                        foreach ($Even in $Events) {
                            $eventxml = [xml]$Even.Toxml()
                            if($eventxml.Event.EventData.Data[0].'#text') {
                                $info = [ordered]@{ 
                                    ComputerName    = $Computer
                                    Date            = $Even.TimeCreated
                                    ProcessName     = $eventxml.Event.EventData.Data[0].'#text'
                                    Reason          = $eventxml.Event.EventData.Data[2].'#text'
                                    "Shutdown Type" = $eventxml.Event.EventData.Data[4].'#text'
                                    Comment         = $eventxml.Event.EventData.Data[5].'#text'
                                    RebootBy        = $eventxml.Event.EventData.Data[6].'#text'
                                    Status          = "Success"                              
                                }       
                                $Rebootinformation = New-Object PSOBject -Property $info   
                                $Rebootinformation 
                            }
                            elseif($eventxml.Event.EventData.Data[0]) {
                                $info = [ordered]@{ 
                                    ComputerName    = $Computer
                                    Date            = $Even.TimeCreated
                                    ProcessName     = $eventxml.Event.EventData.Data[0]
                                    Reason          = $eventxml.Event.EventData.Data[2]
                                    "Shutdown Type" = $eventxml.Event.EventData.Data[4]
                                    Comment         = $eventxml.Event.EventData.Data[5]
                                    RebootBy        = $eventxml.Event.EventData.Data[6]
                                    Status          = "Success"                              
                                }       
                                $Rebootinformation = New-Object PSOBject -Property $info   
                                $Rebootinformation 
                            }
                            else{
                                $info = [ordered]@{ 
                                    ComputerName    = $Computer
                                    Date            = $Even.TimeCreated
                                    ProcessName     = ""
                                    Reason          = ""
                                    "Shutdown Type" = ""
                                    Comment         = ""
                                    RebootBy        = ""
                                    Status          = "Check the XML data"                              
                                }       
                                $Rebootinformation = New-Object PSOBject -Property $info   
                                $Rebootinformation 

                            }

                        }   
                    }
                    else{
                        $info = [ordered]@{ 
                            ComputerName    = $Computer
                            Date            = ""
                            ProcessName     = ""
                            Reason          = ""
                            "Shutdown Type" = ""
                            Comment         = ""
                            RebootBy        = ""
                            Status          = "No Events Found"                    
                        }       
                        $Rebootinformation = New-Object PSOBject -Property $info   
                        $Rebootinformation 

                    }
                                                               
                }                                    
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName    = $Computer
                        Date            = ""
                        ProcessName     = ""
                        Reason          = ""
                        "Shutdown Type" = ""
                        Comment         = ""
                        RebootBy        = ""
                        Status          = "$ErrorMessage"  
                    }                         
                    $Rebootinformation = New-Object PSOBject -Property $info   
                    $Rebootinformation
                }    
            }
            else {
                $info = [ordered]@{ 
                    ComputerName    = $Computer 
                    Date            = ""
                    ProcessName     = ""
                    Reason          = ""
                    "Shutdown Type" = ""
                    Comment         = ""
                    RebootBy        = ""
                    Status          = "Computer is not reachable"                              
                }        
                $Rebootinformation = New-Object PSOBject -Property $info   
                $Rebootinformation
            }   
        }
    }
    End {

    }    
}