function Get-SDPStatsVolumes {
    param(
        [parameter()]
        [Alias("IopsAvg")]
        [string] $iops_avg,
        [parameter()]
        [Alias("IopsMax")]
        [string] $iops_max,
        [parameter()]
        [Alias("LatencyInner")]
        [string] $latency_inner,
        [parameter()]
        [Alias("LatencyOuter")]
        [string] $latency_outer,
        [parameter()]
        [Alias("PeerK2Name")]
        [string] $peer_k2_name,
        [parameter()]
        [Alias("ContainedIn")]
        [int] $resolution,
        [parameter()]
        [Alias("ThroughputAvg")]
        [string] $throughput_avg,
        [parameter()]
        [Alias("ThroughputMax")]
        [string] $throughput_max,
        [parameter()]
        [Alias("ContainedIn")]
        [int] $timestamp,
        [parameter()]
        [Alias("ContainedIn")]
        [string] $volume,
        [parameter()]
        [Alias("VolumeName")]
        [string] $volume_name,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "stats/volumes"

    $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    return $results
}
