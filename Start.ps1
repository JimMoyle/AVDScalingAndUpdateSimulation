. .\Public\Invoke-Greedy.ps1
. .\Public\Invoke-Batch.ps1

$scalingparam = @{
    MaxSessionLogonDays = 5
    MaxConcurrancy = 0.7
    MinConcurrancy = 0.2
    UsersPerServer = 16
    NumberOfServers = 10
}

#Invoke-Greedy @scalingparam
Invoke-Batch @scalingparam -PercentToDrain 0.2