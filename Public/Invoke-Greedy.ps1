function Invoke-Greedy {
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
        [Int]$MaxSessionLogonDays
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

            $hp.Servers | Where-Object { $_.CurrentUserCount -eq 0 } | ForEach-Object {
                $svr = $_
                $svr.Version++ | Out-Null
            }

            if ($hp.Servers.Version -notcontains 1) {
                #Write-Output $hp
                Write-Output "$day"
                return
            }

            $hp = $hp | Add-UsersDepthFill @param
        }

    } #Process
    END {} #End
}  #function Invoke-Greedy
