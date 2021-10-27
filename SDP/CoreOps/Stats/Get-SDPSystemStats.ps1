class sdpsystemstats {
    [string] $blockSize
    [string] $iopsAvg
    [string] $iopsMax
    [string] $throughputAvg
    [string] $throughputMax
    [string] $throughputAvgInMB
    [string] $throughputMaxInMB
    [string] $latencyInnter 
    [string] $latencyOuter
    [string] $peerName
    [datetime] $timestamp
    [string] $resolution
    [string] $rw
}

function Get-SDPSystemStats {
    param(
        [parameter()]
        [switch] $bsBreakdown,
        [parameter()]
        [switch] $rwBreakdown,
        [parameter()]
        [ValidateSet('5m','1h')]
        [string] $resolution,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = 'stats/system'
    }

    process {

        if ($bsBreakdown) {
            $PSBoundParameters.remove('bsBreakdown') | Out-Null
            $PSBoundParameters.__bs_breakdown = $true
        }

        if ($rwBreakdown) {
            $PSBoundParameters.remove('rwBreakdown') | Out-Null
            $PSBoundParameters.__rw_breakdown = $true
        }

        if ($resolution) {
            $PSBoundParameters.remove('resolution') | Out-Null
            $PSBoundParameters.__resolution = $resolution
        }

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI -strictString -noLimit
        
        $eventArray = @()

        foreach ($i in $results) {
            # Object
            # Build an instance of the class
            $classSDPSystemStats = [sdpsystemstats]::new()

            # Populate the class object
            $classSDPSystemStats.blockSize = $i.bs
            $classSDPSystemStats.iopsAvg = $i.iops_avg
            $classSDPSystemStats.iopsMax = $i.iops_max
            $classSDPSystemStats.throughputAvg = $i.throughput_avg
            $classSDPSystemStats.throughputMax = $i.throughput_max
            $classSDPSystemStats.throughputAvgInMB = [math]::Round(($i.throughput_avg / 1mb),2)
            $classSDPSystemStats.throughputMaxInMB = [math]::Round(($i.throughput_max / 1mb),2)
            $classSDPSystemStats.latencyInnter = $i.latency_inner
            $classSDPSystemStats.latencyOuter = $i.latency_outer
            $classSDPSystemStats.peerName = $i.peer_k2_name
            $classTimeStamp = Convert-SDPTimeStampFrom -timestamp $i.timestamp
            $classSDPSystemStats.timestamp = $classTimeStamp
            $classSDPSystemStats.resolution = $i.resolution
            $classSDPSystemStats.rw = $i.rw

            $eventArray += $classSDPSystemStats
        }
        
        
        return $eventArray

    }
}