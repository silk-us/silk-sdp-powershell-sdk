class sdpvolumestats {
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
    [string] $volumeName
}


<#
    .SYNOPSIS
    Retrieves per-volume performance stats from the SDP.

    .DESCRIPTION
    Pulls time-series performance data from the `stats/volumes` endpoint.
    Pipe in a volume from Get-SDPVolume to scope to a single volume, or
    call without -id to retrieve aggregated volume stats.

    .PARAMETER id
    Volume id. Accepts pipeline binding from Get-SDPVolume (pipeId).

    .PARAMETER bsBreakdown
    Split results by block size.

    .PARAMETER rwBreakdown
    Split results by read vs write.

    .PARAMETER fromTime
    Start of the time window (datetime, converted to SDP UTC).

    .PARAMETER dataPoints
    Number of data points to return.

    .PARAMETER resolution
    Time resolution per point. '5m' or '1h'.

    .PARAMETER doNotResolve
    Skip ref resolution. Stats records typically have no refs, so this is
    here for SDK consistency.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolume -name TestVOL | Get-SDPVolumeStats

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPVolumeStats {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [int] $id,
        [parameter()]
        [switch] $bsBreakdown,
        [parameter()]
        [switch] $rwBreakdown,
        [parameter()]
        [datetime] $fromTime,
        [parameter()]
        [int] $dataPoints,
        [parameter()]
        [ValidateSet('5m','1h')]
        [string] $resolution,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "stats/volumes"
    }

    process {
        # Special Ops

        if ($id) {
            $endpoint = "stats/volumes/$id"
            $PSBoundParameters.Remove('id') | Out-Null
        }

        if ($bsBreakdown) {
            $PSBoundParameters.Remove('bsBreakdown') | Out-Null
            $PSBoundParameters.__bs_breakdown = $true
        }

        if ($rwBreakdown) {
            $PSBoundParameters.Remove('rwBreakdown') | Out-Null
            $PSBoundParameters.__rw_breakdown = $true
        }

        if ($fromTime) {
            $PSBoundParameters.Remove('fromTime') | Out-Null
            $paramTime = Convert-SDPTimeStampTo -timestamp $fromTime
            $paramTimeStamp = (Convert-SDPTimeStampFrom -timestamp $paramTime).ToString()
            $PSBoundParameters.__from_time = $paramTime
            Write-Verbose "Using $paramTimeStamp as UTC time"
        }

        if ($dataPoints) {
            $PSBoundParameters.Remove('dataPoints') | Out-Null
            $PSBoundParameters.__datapoints = $dataPoints.ToString()
        }

        if ($resolution) {
            $PSBoundParameters.Remove('resolution') | Out-Null
            $PSBoundParameters.__resolution = $resolution
        }

        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        # Query

        Write-Verbose "Collecting Stats for $endpoint"

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI -strictString -noLimit

        $eventArray = @()

        foreach ($hit in $results) {
            $statsRecord = [sdpvolumestats]::new()

            $statsRecord.blockSize         = $hit.bs
            $statsRecord.iopsAvg           = $hit.iops_avg
            $statsRecord.iopsMax           = $hit.iops_max
            $statsRecord.throughputAvg     = $hit.throughput_avg
            $statsRecord.throughputMax     = $hit.throughput_max
            $statsRecord.throughputAvgInMB = [math]::Round(($hit.throughput_avg / 1mb), 2)
            $statsRecord.throughputMaxInMB = [math]::Round(($hit.throughput_max / 1mb), 2)
            $statsRecord.latencyInnter     = $hit.latency_inner
            $statsRecord.latencyOuter      = $hit.latency_outer
            $statsRecord.peerName          = $hit.peer_k2_name
            $statsRecord.timestamp         = Convert-SDPTimeStampFrom -timestamp $hit.timestamp
            $statsRecord.resolution        = $hit.resolution
            $statsRecord.rw                = $hit.rw
            $statsRecord.volumeName        = $hit.volume_name

            $eventArray += $statsRecord
        }

        if ($doNotResolve) { return $eventArray }
        return ($eventArray | Update-SDPRefObjects -k2context $k2context)
    }
}
