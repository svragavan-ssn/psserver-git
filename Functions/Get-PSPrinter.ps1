Function Get-PSPrinter {
    <#
	.SYNOPSIS
		Adds a user or group as Local Administrator.
	
	.DESCRIPTION
		Adds a user or group as Local Administrator in Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine name to add the account. Defaults to localhost.
	
	.PARAMETER PrinterName
		Name of the printer to get the information
	
	.PARAMETER DriverName
		Group name that needs to be added to Local Administrators group.The group must exist in the Domain.
	
	.EXAMPLE
		Get-PSPrinter -ComputerName SRVTST01 -LocalUser admin
		
        Adds local user account admin in Local Administrators group on machine SRVTST01.
        
	.EXAMPLE
		Get-PSPrinter -ComputerName SRVTST01 -DomainGroup "TST-Admin-Group" -Domain tst.local
		
		Adds Domain Group TST-Admin-Group from domain tst.local in Local Administrators group on computer SRVTST01.The group must exist in tst.local domain.If domain is not specified then logged on user's domain will be taken.

    .EXAMPLE
		Get-PSPrinter -ComputerName SRVTST01 -Domainuser "Serveradmin" -Domain tst.local
        
        Adds Domain User Serveradmin from tst.local domain in Local Administrators group on computer SRVTST01.The user must exist in tst.local domain.If the domain is not specified then logged on user's domain will be taken.
		    
	.NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License: 
#> 
    [cmdletbinding(DefaultParametersetName = "Default")]
    param (
        [parameter(mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(mandatory = $true, ParameterSetName = "printername")]
        [string]$printername,
        [parameter(mandatory = $True, ParameterSetName = "Drivername")]
        [string]$drivername
    )
    begin {

    }
    Process {
        foreach ($computer in $computername) {
            
            If (Test-Connection -ComputerName $computer -Count 1 -quiet:$true) {
                
                Switch ($PsCmdlet.ParameterSetName) {
                    "printername" {
                        
                        try {

                            $printers = Get-Printer -ComputerName $computer -name $printername -ErrorAction Stop
                        
                            foreach ($printer in $printers) {

                                try {
                                
                                    $info = [ordered]@{ 
                                        ComputerName = $Computer                               
                                        PrinterName  = $Printer.Name
                                        DriverName   = $Printer.DriverName
                                        Status       = "Success"
                                    }                         
                                    $Printerstatus = New-Object PSOBject -Property $info   
                                    $Printerstatus
                                }
                                catch {
                                    $ErrorMessage = $_.Exception.Message
                                    $info = [ordered]@{ 
                                        ComputerName = $Computer                               
                                        PrinterName  = $Printer.Name
                                        DriverName   = ""
                                        Status       = $ErrorMessage
                                    }                         
                                    $Printerstatus = New-Object PSOBject -Property $info   
                                    $Printerstatus 		
                                }
                            }
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $info = [ordered]@{ 
                                ComputerName = $Computer                               
                                PrinterName  = ""
                                DriverName   = ""
                                Status       = $ErrorMessage
                            }                         
                            $Printerstatus = New-Object PSOBject -Property $info   
                            $Printerstatus 		
                        }
                    } 
                    "Drivername" {
                        
                        try {

                            $drivers = Get-Printerdriver -ComputerName $computer -name $drivername -ErrorAction Stop
                        
                            foreach ($driver in $drivers) {

                                try {
                                
                                    $info = [ordered]@{ 
                                        ComputerName = $Computer                               
                                        DriverName   = $driver.name
                                        Environment  = $driver.printerenvironment
                                        Status       = "Success"
                                    }                         
                                    $Printerstatus = New-Object PSOBject -Property $info   
                                    $Printerstatus
                                }
                                catch {
                                    $ErrorMessage = $_.Exception.Message
                                    $info = [ordered]@{ 
                                        ComputerName = $Computer                               
                                        DriverName   = $driver.name
                                        Environment  = $driver.printerenvironment
                                        Status       = $ErrorMessage
                                    }                         
                                    $Printerstatus = New-Object PSOBject -Property $info   
                                    $Printerstatus 		
                                }
                            }
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $info = [ordered]@{ 
                                ComputerName = $Computer                               
                                DriverName   = ""
                                Environment  = ""
                                Status       = $ErrorMessage
                            }                         
                            $Printerstatus = New-Object PSOBject -Property $info   
                            $Printerstatus 		
                        }
                    } 
                    Default {
                        
                        try {
                            
                            $printers = Get-Printer -ComputerName $computer -ErrorAction Stop
                        
                            foreach ($printer in $printers) {

                                try {
                                
                                    $info = [ordered]@{ 
                                        ComputerName = $Computer                               
                                        PrinterName  = $Printer.Name
                                        DriverName   = $Printer.DriverName
                                        Status       = "Success"
                                    }                         
                                    $Printerstatus = New-Object PSOBject -Property $info   
                                    $Printerstatus
                                }
                                catch {
                                    $ErrorMessage = $_.Exception.Message
                                    $info = [ordered]@{ 
                                        ComputerName = $Computer                               
                                        PrinterName  = $Printer.Name
                                        DriverName   = ""
                                        Status       = $ErrorMessage
                                    }                         
                                    $Printerstatus = New-Object PSOBject -Property $info   
                                    $Printerstatus 		
                                }
                            }
                        }
                        catch {
                            $ErrorMessage = $_.Exception.Message
                            $info = [ordered]@{ 
                                ComputerName = $Computer                               
                                PrinterName  = ""
                                DriverName   = ""
                                Status       = $ErrorMessage
                            }                         
                            $Printerstatus = New-Object PSOBject -Property $info   
                            $Printerstatus 		
                        }
                    } 
                }
            }
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer                               
                    PrinterName  = ""
                    DriverName   = ""
                    Status       = "Computer is not reachable"
                }                         
                $Printerstatus = New-Object PSOBject -Property $info   
                $Printerstatus 
            }
        }
    }
    end {

        remove-variable -name printerstatus, computername, computer, printername, drivername, info, errormessage, info, driver, printers, drivers, printer -ErrorAction SilentlyContinue
    }
}
