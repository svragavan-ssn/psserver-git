Function New-PSPrinter {
    <#
	.SYNOPSIS
		Adds a user or group as Local Administrator.
	
	.DESCRIPTION
		Adds a user or group as Local Administrator in Local machine or Remote machine.
	
	.PARAMETER ComputerName
		The target machine name to add the account. Defaults to localhost.
	
	.PARAMETER PrinterName
		Name of the printer to get the information.
	
	.PARAMETER DriverName
        Driver name that needs to be assigned for the printer.

    .PARAMETER Size
        Size that needs to be assigned for the printer.
        
	.PARAMETER Duplex
        Duplex that needs to be assigned for the printer.
        
	.EXAMPLE
		New-PSPrinter -ComputerName SRVTST01 -PrinterName "Printer01"
		
        Creates new printer Printer01 in computer SRVTST01. DNS record has to be there for Printer01.
        
	.EXAMPLE
		New-PSPrinter -ComputerName SRVTST01 -PrinterName "Printer01" -drivername "HP Universal Printing PCL 6 (v6.5.0)" -size "Letter" -Duplex "TwoSidedLongEdge"
		
		Creates new printer Printer01 in computer SRVTST01.Assigns HP driver,sets paper size to letter and sets duplex to twoside.    
		    
	.NOTES
        Author: Vijayaragavan S (@Ragavanvs)
        Tags: 
		
		Website: 
		Copyright: (C) Vijayaragavan
		License: 
#> 
    [cmdletbinding()]
    param (
        [parameter(mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(mandatory = $true)]
        [string]$printername,
        [parameter(mandatory = $false)]
        [string]$drivername = "HP Universal Printing PCL 6 (v6.5.0)",
        [parameter(mandatory = $false)]
        [string]$size = "A4",
        [parameter(mandatory = $false)]
        [ValidateSet("OneSided", "TwoSidedLongEdge", "TwoSidedShortEdge")]        
        [string]$Duplex = "TwoSidedLongEdge"
    )

    begin {

    }
    Process {
        foreach ($computer in $computername) {
            
            If (Test-Connection -ComputerName $computer -Count 1 -quiet:$true) {                
                
                try {
                    Write-output "Checking Printer"
                    if (Get-Printer -ComputerName $computer -name $printername -ErrorAction SilentlyContinue) {
                        
                        $info = [ordered]@{ 
                            ComputerName = $Computer                               
                            PrinterName  = $printername                            
                            Status       = "Printer Already exist in Server"
                        }                         
                        $Printerstatus = New-Object PSOBject -Property $info   
                        $Printerstatus
                    }
                    else {
                                               
                        $ipinfo = Get-PSNametoIp $printername -ErrorAction Stop                       
                        Add-PrinterPort -Name $printername -computername $computer -PrinterHostAddress $ipinfo.ip
                        Start-Sleep -Seconds 5
                        add-printer -Name $printername -DriverName $drivername -computername $computer -ShareName $printername -PortName $printername -Shared                        
                        Start-Sleep -Seconds 5                        
                        Set-PrintConfiguration -computername $computer -PrinterName $printername -PaperSize $size -DuplexingMode $Duplex                        
                        #invoke-expression -command "rundll32 printui.dll,PrintUIEntry /Xs /n '$printername' attributes -EnableBidi"
                        #invoke-expression -command "WMIC /node:$computer process call create cmd.exe /c rundll32 printui.dll,PrintUIEntry /Xs /n '$printername' attributes -EnableBidi"                    
                        $info = [ordered]@{ 
                            ComputerName = $Computer                               
                            PrinterName  = $printername                            
                            Status       = "Printer has been created"
                        }                         
                        $Printerstatus = New-Object PSOBject -Property $info   
                        $Printerstatus
                    }                                                          
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName = $Computer                               
                        PrinterName  = ""                       
                        Status       = $ErrorMessage
                    }                         
                    $Printerstatus = New-Object PSOBject -Property $info   
                    $Printerstatus 		
                }                                                           
            }
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer                               
                    PrinterName  = ""                   
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