Function Get-PSServerconfig {
<#
	.SYNOPSIS
		Provides system configuration information.
	
	.DESCRIPTION
		Provides information related to installed processor,os and Maunufacturer information from local or remote machine.
	
	.PARAMETER ComputerName
		The target machine name to get the information.Defaults to localhost.
	
    .EXAMPLE
		Get-PSServerconfig
		
		Gets the information of local machine.

    .EXAMPLE
		Get-PSServerconfig -computername SRVTST01,SRVTST02
		
		Gets the information from SRVTST01 and SRVTST02.

    .EXAMPLE
		Get-content .\list.txt |Get-PSServerconfig
        
        Keep multiple machine name in TXT file to get their information.
    
    .EXAMPLE
		Import-Csv .\list.csv | Get-PSServerconfig
        
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
        [parameter(Mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$computername = $env:COMPUTERNAME
    )
    Begin {

    }        
    Process {
        foreach ($Computer in $ComputerName) { 
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {                  
                    $server = Get-WmiObject win32_computersystem -ComputerName $Computer -ErrorAction Stop 
                    $processor = Get-WmiObject win32_processor -ComputerName $Computer -ErrorAction Stop 
                    $os = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
                    $info = [ordered]@{ 
                        ComputerName          = $Computer
                        Domain                = $server.domain
                        Manufacturer          = $server.Manufacturer
                        'RAM/GB'              = [math]::Round(($server.TotalPhysicalMemory / 1GB), 2)
                        Processorname         = @($processor)[0].name
                        'Processor(N)'        = $server.NumberOfProcessors
                        'LogicalProcessor(N)' = $server.NumberOfLogicalProcessors
                        OperatingSystem       = $os.name.split('|')[0]
                        ServicepackMajor      = $os.ServicePackMajorVersion
                        ServicepackMinor      = $os.ServicePackMinorVersion
                        Status                = "Success"
                    }                           
                    $serverinformation = New-Object PSOBject -Property $info   
                    $serverinformation                       
                }                                    
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName          = $Computer
                        Domain                = ""
                        Manufacturer          = ""
                        'RAM/GB'              = ""
                        Processorname         = ""
                        'Processor(N)'        = ""
                        'LogicalProcessor(N)' = ""
                        OperatingSystem       = ""
                        ServicepackMajor      = ""
                        ServicepackMinor      = ""  
                        Status                = $ErrorMessage
                    }                         
                                            
                    $serverinformation = New-Object PSOBject -Property $info   
                    $serverinformation 
                }    
            }
            else {
                $info = [ordered]@{ 
                    ComputerName          = $Computer 
                    Domain                = ""
                    Manufacturer          = ""
                    'RAM/GB'              = ""
                    Processorname         = ""
                    'Processor(N)'        = ""
                    'LogicalProcessor(N)' = ""
                    OperatingSystem       = ""
                    ServicepackMajor      = ""
                    ServicepackMinor      = ""  
                    Status                = "Computer is not reachable"
                }   
                $serverinformation = New-Object PSOBject -Property $info   
                $serverinformation
            }         
        }
    }     
    End {

    }
} 