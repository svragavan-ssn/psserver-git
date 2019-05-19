Function Get-PSReboottime {
    <#
        .SYNOPSIS
            Invokes ICMP request to find the computer's connection state.
        
        .DESCRIPTION
            This function is simillar to Ping command.Invokes ICMP requests to find the computer's connection state.
        
        .PARAMETER ComputerName
            The target machine name to check connection state.The value is mandatory
        
        .EXAMPLE
            Get-PSReboottime -computername SRVTST01,SRVTST02
            
            Checks availability of machine SRVTST01 and SRVTST02.
    
        .EXAMPLE
            Get-content .\list.txt | Get-PSReboottime
            
            Keep multiple machine name in TXT file to get their availability.
        
        .EXAMPLE
            Import-Csv  .\list.csv | Get-PSReboottime
            
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
                $res="True"
                $starttime=Get-Date
                while($res -eq "true"){
                  $res=Test-connection $computer -count 1 -quiet:$true
                  $uptime=Get-Date
                  if(($uptime-$starttime).Minutes -ge 1){
                
                    $info = [ordered]@{ 
                        ComputerName = $Computer 
                        Minutes=""
                        seconds=""
                        Status       = "Server is up and running "                              
                    }                         
                    $pingstatus = New-Object PSOBject -Property $info   
                    $pingstatus
                    break
                }  
                }
                $downon=Get-Date                  
                $res="false"
                
                
                do{
                    $res=Test-connection $computer -count 1 -quiet:$true
                    
                    $down=Get-Date
                    if(($down-$downon).Minutes -ge 1){

                        $info = [ordered]@{ 
                        ComputerName = $Computer 
                        Minutes=""
                        seconds=""
                        Status       = "Check the Server"                              
                        }                         
                        $pingstatus = New-Object PSOBject -Property $info   
                        $pingstatus
                        $downon=0
                        break
                    } 
                                          
                }until($res -eq "false")
                $upon=Get-Date
                
                if($downon -ne 0){
                    $rebootminutes=($upon-$downon).Minutes
                    $rebootseconds=($upon-$downon).Seconds
                    
                    $info = [ordered]@{ 
                        ComputerName = $Computer 
                        Minutes=$rebootminutes
                        seconds=$rebootseconds
                        Status       = "Success"                              
                    }                         
                    $pingstatus = New-Object PSOBject -Property $info   
                    $pingstatus

                }
            }
        }
        End {
    
        }    
    }