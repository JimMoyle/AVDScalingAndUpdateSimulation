. .\Public\Invoke-Greedy.ps1
. .\Public\Invoke-Batch.ps1
. .\Public\Invoke-TraditionalBatch.ps1

$total = foreach ($num in 1..10 | ForEach-Object { $_ * 10 }) {
    Write-Host "Starting number $num"
    $avg = @()

    $blah = foreach ($i in (1..10)) {
        Write-Host "Starting run $i"

        $MaxSessionLogonDays = 3
        $MaxConcurrancy = 0.7
        $MinConcurrancy = 0.2
        $UsersPerServer = 12
        $NumberOfServers = $num

        $scalingparam = @{
            MaxSessionLogonDays = $MaxSessionLogonDays
            MaxConcurrancy      = $MaxConcurrancy
            MinConcurrancy      = $MinConcurrancy
            UsersPerServer      = $UsersPerServer
            NumberOfServers     = $NumberOfServers
        }

        $g = Invoke-Greedy @scalingparam
        $b = Invoke-Batch @scalingparam -PercentToDrain 0.2
        $tb = Invoke-TraditionalBatch @scalingparam -PercentToDrain 0.2

        $run = [PSCustomObject]@{
            Greedy    = $g
            Batch     = $b
            TradBatch = $tb
        }
        $run
    }
    $j = [PSCustomObject]@{
        Greedy              = ($blah | Measure-Object -Property Greedy -Average).Average
        Batch               = ($blah | Measure-Object -Property Batch -Average).Average
        TradBatch           = ($blah | Measure-Object -Property TradBatch -Average).Average
        MaxSessionLogonDays = $MaxSessionLogonDays
        MaxConcurrancy      = $MaxConcurrancy
        MinConcurrancy      = $MinConcurrancy
        UsersPerServer      = $UsersPerServer
        NumberOfServers     = $NumberOfServers
    }

    $j
}
$total