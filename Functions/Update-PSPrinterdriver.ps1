Function Update-PSPrinterdriver {
    <#
	.SYNOPSIS
		Updates printer driver to the given version.
	
	.DESCRIPTION
		Updates printer driver to the given version.When changing driver from one version to another version then the current settings will not be retained.This script will retain the current settings and apply the same after driver update.
	
	.PARAMETER ComputerName
		The target machine name to update the printer. Defaults to localhost.
	
	.PARAMETER PrinterName
		Specify the name of the printer to update.This parameter is mandatory .
	
	.PARAMETER DriverName
        Driver Name that needs to be assigned to the printer.This parameter is mandatory.
        
	.EXAMPLE
		Update-PSPrinterdriver -ComputerName SRVTST01 -PrinterName "Printer01" -DriverName "HP Universal Printer Driver (V6.5.0)"
		
        Updates Printer01's driver to "HP Universal Printer Driver (V6.5.0)" ,Printer is available in machine SRVTST01 .
        
	.EXAMPLE
		Update-PSPrinterdriver -PrinterName "Printer01" -DriverName "HP Universal Printer Driver (V6.5.0)"
		
		Updates Printer01's driver to "HP Universal Printer Driver (V6.5.0)" ,Printer is available in local host .
      
	.NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License: 
#> 
    [cmdletbinding()]
    param (
        [parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$printerName,
        [parameter(Mandatory = $True)]
        [string]$drivername
    )

    begin {


    }

    Process {

        foreach ($computer in $computername) {

            If (Test-Connection -ComputerName $computer -Count 1 -quiet:$true) {                

                foreach ($printer in $printerName) {
                    try {
                        
                        $printerconfig = get-printconfiguration -PrinterName $printer -ComputerName $computer  -ErrorAction Stop                                                           
                        
                        Set-Printer -Name $printer -DriverName $drivername -ComputerName $computer    
                        #set-printconfiguration -inputobject $printerconfig   
                        Set-PrintConfiguration -PrinterName $printer -ComputerName $computer -PaperSize $printerconfig.papersize -DuplexingMode $printerconfig.DuplexingMode
                                                
                        #invoke-expression -command "WMIC /node:$computer process call create cmd.exe /c rundll32 printui.dll,PrintUIEntry /Xs /n '$printername' attributes -EnableBidi"                    
                        #invoke-expression -command "rundll32 printui.dll,PrintUIEntry /Xs /n '$printername' attributes -EnableBidi"                                                  

                        $info = [ordered]@{ 
                            ComputerName = $Computer                               
                            PrinterName  = $printer
                            DriverName   = $drivername
                            Status       = "Success"
                        }                         
                        $Printerstatus = New-Object PSOBject -Property $info   
                        $Printerstatus                        
                    }                     		                                                
                    catch {

                        $ErrorMessage = $_.Exception.Message
                        $info = [ordered]@{ 
                            ComputerName = $Computer                               
                            PrinterName  = $Printer
                            DriverName   = ""
                            Status       = $ErrorMessage
                        }                         
                        $Printerstatus = New-Object PSOBject -Property $info   
                        $Printerstatus                      
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
        Remove-Variable -Name TrayFormFirstAndLastTraysOption,TrayFormKeyword,TrayFormKeywordSize,TrayFormMap,TrayFormMapSize,TrayFormSize,Trayformtable -ErrorAction SilentlyContinue
    }
}
