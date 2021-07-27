function Invoke-TraditionalBatch {
    [CmdletBinding()]

    Param (
        [Parameter(
            Mandatory = $true
        )]
        [Int]$NumberOfServers,

        [Parameter(
            Mandatory = $true
        )]
        [Int]$UsersPerServer,

        [Parameter(
            Mandatory = $true
        )]
        [Double]$MaxConcurrancy,

        [Parameter(
            Mandatory = $true
        )]
        [Double]$MinConcurrancy,

        [Parameter(
            Mandatory = $true
        )]
        [Int]$MaxSessionLogonDays,

        [Parameter(
        )]
        [Double]$PercentToDrain = 0.2

    )

    BEGIN {
        Set-StrictMode -Version Latest
        . .\Public\Add-UsersDepthFill.ps1
        . .\Public\Add-UsersBreadthFill.ps1
        . .\Public\Remove-UserBatch.ps1

        . .\Private\New-HostPoolObject.ps1
        . .\Private\Remove-User.ps1
    } # Begin
    PROCESS {

        $day = 0
        $NewDrainFlag = $true

        $param = @{
            NumberOfServers     = $NumberOfServers
            UsersPerServer      = $UsersPerServer
            MaxConcurrancy      = $MaxConcurrancy
            MinConcurrancy      = $MinConcurrancy
            MaxSessionLogonDays = $MaxSessionLogonDays
        }

        $hp = Add-UsersBreadthFill @param

        while ($hp.Servers.Version -contains 1) {
            $hp = $hp | Remove-UserBatch (($MaxConcurrancy - $MinConcurrancy) * ($NumberOfServers * $UsersPerServer))

            foreach ($session in $hp.Servers.Users) {
                $session.sessionage++
                if ($session.sessionage -gt $MaxSessionLogonDays) {
                    $hp | Remove-User -UserName $session | Out-Null
                }
            }

            $day++

            $serversToDrain = [math]::Floor($NumberOfServers * $PercentToDrain)

            $drainingServers = $hp.Servers | Where-Object {$_.AllowNewConnections -eq $false}

            if (($day % $MaxSessionLogonDays) -eq 0) {
                if ($drainingServers -and ($drainingServers.CurrentUserCount | Measure-Object -Sum).Sum -eq 0) {
                    $hp.Servers | Where-Object { $_.AllowNewConnections -eq $false } | ForEach-Object {
                        $svr = $_
                        $svr.version++
                        $svr.AllowNewConnections = $true
                        $NewDrainFlag = $true
                    }
                }
            }


            if ($NewDrainFlag -eq $true) {
                $hp.Servers | Where-Object {$_.Version -eq 1} |Sort-Object -Property CurrentUserCount | Select-Object -First $serversToDrain | ForEach-Object {
                    $_.AllowNewConnections = $false
                    $NewDrainFlag = $false
                }
            }

            $hp = $hp | Add-UsersBreadthFill @param

            if ($hp.Servers.Version -notcontains 1) {
                #Write-Output $hp
                Write-Output "$day"
                return
            }
        }

    } #Process
    END {} #End
}  #function Invoke-TraditionalBatch
