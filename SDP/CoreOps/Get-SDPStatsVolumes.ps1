<#
    .SYNOPSIS
    Retrieves volume performance statistics from the SDP.

    .DESCRIPTION
    Queries for volume performance metrics on the Silk Data Pod. Returns statistics including IOPS, latency, and throughput for volumes.

    .PARAMETER iops_avg
    Filter by average IOPS value.

    .PARAMETER iops_max
    Filter by maximum IOPS value.

    .PARAMETER latency_inner
    Filter by inner latency (SDP internal latency).

    .PARAMETER latency_outer
    Filter by outer latency (total latency including network).

    .PARAMETER peer_k2_name
    Filter by peer SDP name for replication statistics.

    .PARAMETER resolution
    Time resolution for statistics in seconds.

    .PARAMETER throughput_avg
    Filter by average throughput value.

    .PARAMETER throughput_max
    Filter by maximum throughput value.

    .PARAMETER timestamp
    Filter by specific timestamp (Unix epoch time).

    .PARAMETER volume
    Filter by volume reference.

    .PARAMETER volume_name
    Filter by volume name.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPStatsVolumes
    Retrieves statistics for all volumes.

    .EXAMPLE
    Get-SDPStatsVolumes -volume_name "Vol01"
    Retrieves statistics for the volume named "Vol01".

    .EXAMPLE
    Get-SDPStatsVolumes -resolution 3600
    Retrieves hourly statistics for all volumes.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
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
