Function Get-PSTime {
    <#
        .SYNOPSIS
            Gets local time and timezone information.
        
        .DESCRIPTION
            ets local time and timezone information from Local machine or Remote machine.
        
        .PARAMETER ComputerName
            The target machine name to get the information. Defaults to localhost.
        
        .EXAMPLE
            Get-PSTime
            
            Gets local time and timezone information of local machine.
        
        .EXAMPLE
           Get-PSTime -computername SRVTST01,SRVTST02
            
            Gets local time and timezone information of machine SRVTST01 and SRVTST02.
    
        .EXAMPLE
            Get-content .\list.txt | Get-PSTime
            
            Keep multiple machine name in TXT file to get their local time and timezone information.
        
        .EXAMPLE
            Import-Csv  .\list.csv | Get-PSTime
            
            Keep multiple machine name in CSV file to get their local time and timezone information.The header name must be Computername.
            
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
                        
                    $timeZone = Get-WmiObject -Class win32_timezone -ComputerName $computer 
                    $localTime = Get-WmiObject -Class win32_localtime -ComputerName $computer                     
                    $month = $localTime.month
                    $day = $localTime.day
                    $year = $localTime.year
                    $hour = $localTime.hour
                    $minute = $localTime.minute
                    $second = $localTime.second
                    $zone = $timeZone.Caption 
                    $separator = " "
                    $zne = $zone.split($separator, 2)

                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        UTC          = $zne[0]
                        Zone         = $zne[1]
                        'Local Time' = "$month" + "/" + "$day" + "/" + "$year" + " " + "$hour" + ":" + "$Minute" + ":" + "$second"
                        Status       = "Success" 
                    }                   
                    $timeinformation = New-Object PSOBject -Property $info  
                    $timeinformation    
                                                       
                }  
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        UTC          = ""
                        Zone         = ""
                        'Local Time' = ""
                        Status       = "$ErrorMessage" 
                    } 
                    $timeinformation = New-Object PSOBject -Property $info  
                    $timeinformation
                }    
            }  
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer
                    UTC          = ""
                    Zone         = ""
                    'Local Time' = ""                    
                    Status       = "Computer is not Reachable" 
                } 
                $timeinformation = New-Object PSOBject -Property $info  
                $timeinformation  
            }
        }
    }
    End {
    
    }
}