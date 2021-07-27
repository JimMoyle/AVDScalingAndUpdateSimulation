function Simulate-Logoff {
    [CmdletBinding()]

    Param (
        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [int]$NumberOfServers = 32,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [int]$UsersPerServer = 16,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [double]$MaxConcurrancy = 0.7,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [double]$MinConcurrancy = 0.4,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [double]$StartVersion = 1,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [Int]$MaxSessionLogonDays = 5
    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {

        #Max users
        $totalMaxUsers = $NumberOfServers * $UsersPerServer * $MaxConcurrancy

        $totalMinUsers = $NumberOfServers * $UsersPerServer * $MinConcurrancy

        #assuming breadth mode to start with
        #Occupied servers at lowest ebb
        $ServerFill = $totalMinUsers / $NumberOfServers

        $serverBuckets = @()

        foreach ($server in 1..$NumberOfServers) {

            $add = [PSCustomObject]@{
                ServerName = $server
                Users      = [System.Collections.ArrayList]
                Version    = $StartVersion
                AllowLogon = $true
            }

            $serverBuckets += $add
        }

        [System.Collections.ArrayList]$userArray = 1..$totalUsers

        $serverIncrement = 0

        while ($userArray.count -gt ($totalUsers * $MinConcurrancy)) {
            $randomUser = $userArray | Get-Random

            $bucket = [math]::Ceiling($randomUser / $UsersPerServer)

            $bucketToAddto = $serverBuckets | Where-Object { $_.ServerName -eq $bucket }

            $bucketToAddto.UsersLoggedOff = $bucketToAddto.UsersLoggedOff + 1

            if ($bucketToAddto.UsersLoggedOff -eq $UsersPerServer) {
                $serverIncrement++
                $output = [PSCustomObject]@{
                    ServerEmpty    = $serverIncrement
                    UsersLoggedOff = $totalUsers - $userArray.count
                }
                Write-Output $output
            }

            $userArray.Remove($randomUser)
        }

    } #Process
    END { } #End
}  #function Simulate-Logoff

#run siumulation 100 times
$i = 0
$numberOfSimsToRun = 100
While ($i -lt $numberOfSimsToRun) {
    $result = Simulate-Logoff -NumberOfServers 8 -UsersPerServer 256
    $out = $result | Where-Object { $_.ServerEmpty -eq 1 } | Select-Object -Property UsersLoggedOff
    $out
    $out | Export-Csv -Append -Path d:\jimm\simulate8servers256users.csv
    $i++
}