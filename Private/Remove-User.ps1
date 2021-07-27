function Remove-User {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        $UserName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [PSTypeName('Sim.HostPool')]$InputObject
    )

    BEGIN {
        Set-StrictMode -Version Latest
    } # Begin
    PROCESS {
        $userToRemove = $UserName
        $userToRemove.SessionAge = 0
        $hostPool = $InputObject
        $server = $hostPool.Servers | Where-Object { $_.CurrentUserCount -gt 0 } | Where-Object { $_.Users.userName -contains $userToRemove.userName }
        $server.Users.Remove($userToRemove)
        $server.CurrentUserCount = $server.Users.Count
        $HostPool.UserPool.add($userToRemove) | Out-Null

        Write-Output $hostPool
    } #Process
    END {} #End
}  #function Remove-User