function New-HostPoolObject {
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

        [Parameter()]
        [Int]$StartVersion = 1,

        [Parameter()]
        [double]$MaxConcurrancy = 0.7,

        [Parameter()]
        [double]$MinConcurrancy = 0.4


    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {
        $maxConcurrantUsers = [math]::Ceiling($NumberOfServers * $UsersPerServer * $MaxConcurrancy)

        #Create list of users
        [System.Collections.ArrayList]$userPool = @()
        foreach ($user in 1..$maxConcurrantUsers) {

            $add = [PSCustomObject]@{
                UserName   = $user
                SessionAge = 0
            }
            $userPool += $add
        }

        $servers = @()

        foreach ($server in 1..$NumberOfServers) {

            $add = [PSCustomObject]@{
                ServerName          = $server
                CurrentUserCount    = 0
                Users               = [System.Collections.ArrayList]@{}
                MaxUsers            = $UsersPerServer
                Version             = $StartVersion
                AllowNewConnections = $true
            }

            $servers += $add
        }

        $hostPool = [PSCustomObject]@{
            PSTypeName         = "Sim.Hostpool"
            MaxUsers           = $NumberOfServers * $UsersPerServer
            MaxConcurrantUsers = $maxConcurrantUsers
            MinConcurrantUsers = [math]::Ceiling($NumberOfServers * $UsersPerServer * $MinConcurrancy)
            Servers            = $servers
            UserPool           = $userPool
        }

        Write-Output $hostPool

    } #Process
    END {} #End
}  #function New-HostPoolObject