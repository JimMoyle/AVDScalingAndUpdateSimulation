function Remove-UserBatch {
    [CmdletBinding()]

    Param (
        [Parameter(
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [PSTypeName('Sim.HostPool')]$HostPool,

        [Parameter(
            Position = 0,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [Int]$NumberUsersToRemove

    )

    BEGIN {
        Set-StrictMode -Version Latest
        . .\Private\Remove-User.ps1
    } # Begin
    PROCESS {
        if ($NumberUsersToRemove -gt $HostPool.Servers.Users.Count){
            $NumberUsersToRemove = $HostPool.Servers.Users.Count
        }

        $target = $HostPool.Servers.Users.Count - $NumberUsersToRemove
        while ($HostPool.Servers.Users.Count -gt $target ) {
            $userlist = $HostPool.Servers.Users
            $userToRemove = $userlist | Get-Random

            $HostPool = $HostPool | Remove-User -Username $userToRemove
        }

        Write-Output $HostPool
    } #Process
    END {} #End
}  #function Remove-Users