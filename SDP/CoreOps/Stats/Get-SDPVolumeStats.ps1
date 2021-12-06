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


function Get-SDPVolumeStats {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [int] $id,
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

    <#
        .SYNOPSIS

        .EXAMPLE    
            Get-SDPVolume -name TestVOL | Get-SDPVolumeStats

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://github.com/silk-us/silk-sdp-powershell-sdk

    #>

    begin {
        $endpoint = "stats/volumes"
    }

    process {
        # Special Ops

        if ($id) {
            Remove-variable endpoint
            $endpoint = 'stats/volumes/' + $id
            $PSBoundParameters.remove('id') | Out-Null
        }

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

        # Query 

        Write-Verbose "Collecting Stats for $endpoint"
        
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI -strictString -noLimit
        # $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -k2context $k2context 
        
        $eventArray = @()

        foreach ($i in $results) {
            # Object
            # Build an instance of the class
            $classSDPvolumeStats = [sdpvolumestats]::new()

            # Populate the class object
            $classSDPvolumeStats.blockSize = $i.bs
            $classSDPvolumeStats.iopsAvg = $i.iops_avg
            $classSDPvolumeStats.iopsMax = $i.iops_max
            $classSDPvolumeStats.throughputAvg = $i.throughput_avg
            $classSDPvolumeStats.throughputMax = $i.throughput_max
            $classSDPvolumeStats.throughputAvgInMB = [math]::Round(($i.throughput_avg / 1mb),2)
            $classSDPvolumeStats.throughputMaxInMB = [math]::Round(($i.throughput_max / 1mb),2)
            $classSDPvolumeStats.latencyInnter = $i.latency_inner
            $classSDPvolumeStats.latencyOuter = $i.latency_outer
            $classSDPvolumeStats.peerName = $i.peer_k2_name
            $classTimeStamp = Convert-SDPTimeStampFrom -timestamp $i.timestamp
            $classSDPvolumeStats.timestamp = $classTimeStamp
            $classSDPvolumeStats.resolution = $i.resolution
            $classSDPvolumeStats.rw = $i.rw
            $classSDPvolumeStats.volumeName = $i.volume_name

            $eventArray += $classSDPvolumeStats
        }
        
        
        return $eventArray
    }
}
