Function Get-PSUsage {
    <#
        .SYNOPSIS
            Gets CPU,Memory and disk queue length Usage information.
        
        .DESCRIPTION
            Gets CPU,Memory and disk queue length Usage information from Local machine or Remote machine.
        
        .PARAMETER ComputerName
            The target machine name to get the information. Defaults to localhost.
        
        .EXAMPLE
            Get-PSUsage
            
            By default Gets CPU Usage information of local machine.
        
        .EXAMPLE
            Get-PSUsage -cpu
            
            Gets CPU Usage information of local machine.
        .EXAMPLE
            Get-PSUsage -memory
            
            Gets Memory Usage information of local machine.
        .EXAMPLE
            Get-PSUsage -dskqueue
            
            Gets disk queue length information of local machine.
    
        .EXAMPLE
            Get-PSUsage -cpu -computername SRVTST01
            
            Gets CPU Usage information from remote machine SRVTST01.
    
        .EXAMPLE
            Get-content .\list.txt | Get-PSUsage
            
            Keep multiple machine name in TXT file to Get CPU Usage information.
        
        .EXAMPLE
            Import-Csv  .\list.csv | Get-PSUsage
            
            Keep multiple machine name in CSV file to get CPU Usage information.The header name must be Computername.
            
        .NOTES
            Author: Vijayaragavan S (@Ragavanvs)
            Tags: 
            
            Website: 
            Copyright: (C) Vijayaragavan
            License:  
    #>     
    [cmdletbinding(DefaultParameterSetName = "CPU")]
    param (    
        [parameter(Mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$computername = $env:COMPUTERNAME,
        [parameter(ParameterSetName = "CPU")]   
        [switch]$cpu,
        [parameter(ParameterSetName = "Memory")]   
        [switch]$Memory,
        [parameter(ParameterSetName = "Diskqueue")]   
        [switch]$dskqueue
    )
    Begin {
        Switch ($pscmdlet.ParameterSetName) {
            "CPU" {
                $counter = "\Processor(_Total)\% Processor Time"
            }   
            "Memory" {
                $counter = "\memory\Available Bytes"
            }  
            "Diskqueue" {
                $counter = "\LogicalDisk(*)\Current Disk Queue Length"
            }
            default {
                $counter = "\Processor(_Total)\% Processor Time"
            } 
        }  
    }        
    Process {
        foreach ($Computer in $ComputerName) {
            if (Test-connection $computer -count 1 -quiet:$true) {
                try {                                         
                    
                    if ($pscmdlet.ParameterSetName -eq "CPU") {
                        $counterdata = Get-Counter -Counter $counter -ComputerName $Computer -SampleInterval 2 -MaxSamples 5
                        $data = $counterdata.countersamples | Measure-Object -Property cookedvalue -Average -Minimum -Maximum

                        $info = [ordered]@{ 
                            ComputerName    = $Computer
                            MaximumCPUUsage = $data.Maximum
                            MinimumCPUUsage = $data.Minimum
                            AverageCPUUsage = $data.Average
                            Status          = "Success" 
                        }                   
                        $cpuinformation = New-Object PSOBject -Property $info  
                        $cpuinformation                                 
                    }
                    
                    if ($pscmdlet.ParameterSetName -eq "Memory") {
                        $counterdata = Get-Counter -Counter $counter -ComputerName $Computer 
                        $availablememory = [math]::Round(($counterdata.countersamples.cookedvalue / 1GB), 2)
                        $server = Get-WmiObject win32_computersystem -ComputerName $Computer -ErrorAction Stop 
                        $totalmemory = [math]::Round(($server.TotalPhysicalMemory / 1GB), 2)
                       
                        $processinfo = get-process -ComputerName "alinedc01" |Select-Object Name, @{Name = 'WorkingSet'; Expression = {($_.WorkingSet / 1MB)}} |Sort-Object workingset -desc | Select-Object -first 1

                        $info = [ordered]@{ 
                            ComputerName        = $Computer
                            'MemoryUsed %'      = (($totalmemory - $availablememory) / $totalmemory) * 100
                            'FreeMemory/GB'     = $availablememory
                            'UsedMemory/GB'     = $totalmemory - $availablememory
                            'TotalMemory/GB'    = $totalmemory
                            ProcessName         = $processinfo.name
                            'Process Memory/MB' = $processinfo.workingset
                            Status              = "Success" 
                        }                   
                        $Memusageinformation = New-Object PSOBject -Property $info  
                        $Memusageinformation                                 
                    } 
                    if ($pscmdlet.ParameterSetName -eq "Diskqueue") {
                        $counterdata = Get-Counter -Counter $counter -ComputerName $Computer -SampleInterval 2 -MaxSamples 5
                        $data = $counterdata.countersamples | Measure-Object -Property cookedvalue -Average -Minimum -Maximum

                        $info = [ordered]@{ 
                            ComputerName   = $Computer
                            MaxDskQueuelen = $data.Maximum
                            MinDskQueuelen = $data.Minimum
                            AveDskQueuelen = $data.Average
                            Status         = "Success" 
                        }                   
                        $dskqueinformation = New-Object PSOBject -Property $info  
                        $dskqueinformation                                  
                    }                                        
                }  
                catch { 
                    $ErrorMessage = $_.Exception.Message
                    $info = [ordered]@{ 
                        ComputerName = $Computer
                        CPUUsage     = ""
                        Status       = "$ErrorMessage" 
                    } 
                    $cpuinformation = New-Object PSOBject -Property $info  
                    $cpuinformation
                }    
            }  
            else {
                $info = [ordered]@{ 
                    ComputerName = $Computer
                    CPUUsage     = ""
                    Status       = "Computer is not Reachable" 
                } 
                $cpuinformation = New-Object PSOBject -Property $info  
                $cpuinformation  
            }
        }
    }
    End {
    
    }
}
