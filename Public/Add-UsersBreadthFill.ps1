function Add-UsersBreadthFill {
    [CmdletBinding()]

    Param (
        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [int]$NumberOfServers = 10,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [int]$UsersPerServer = 4,

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
        [Int]$MaxSessionLogonDays = 5,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [Int]$NumberToAdd,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [PSTypeName('Sim.HostPool')]$InputObject
    )

    BEGIN {
        Set-StrictMode -Version Latest
        . .\Private\New-HostPoolObject.ps1
    } # Begin
    PROCESS {

        $maxConcurrantUsers = [math]::Ceiling($NumberOfServers * $UsersPerServer * $MaxConcurrancy)

        if (!$NumberToAdd){
            $NumberToAdd = $maxConcurrantUsers
        }

        if ($NumberToAdd -gt $maxConcurrantUsers) {
            Write-Warning "Trying to add $NumberToAdd while Max Concurrancy is $maxConcurrantUsers Have set to $maxConcurrantUsers "
            $NumberToAdd = $maxConcurrantUsers
        }

        if (!$InputObject) {
            #Create Host Pool Object
            $newHostPoolObjectParam = @{
                NumberOfServers = $NumberOfServers
                UsersPerServer  = $UsersPerServer
                MaxConcurrancy  = $MaxConcurrancy
                MinConcurrancy  = $MinConcurrancy
            }
            $hostpool = New-HostPoolObject @newHostPoolObjectParam
        }
        else{
            $hostpool = $InputObject
        }

        #BreadthFirst
        while ( ($hostPool.Servers.CurrentUserCount | Measure-Object -Sum | Select-Object -ExpandProperty Sum) -lt $NumberToAdd) {

            $OpenServer = $hostPool.Servers | Where-Object { $_.AllowNewConnections -eq $true} | Sort-Object -Property CurrentUserCount | Select-Object -First 5 | Get-Random

            $User = $hostPool.UserPool | Get-Random

            $OpenServer.Users.add($User) | Out-Null
            $OpenServer.CurrentUserCount = $OpenServer.Users.Count
            $hostPool.UserPool.Remove($User)

        }

        $output = $hostPool

        Write-Output $output

    }
    END {

    }
}