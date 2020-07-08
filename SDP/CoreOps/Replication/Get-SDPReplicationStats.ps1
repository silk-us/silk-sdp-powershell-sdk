function Get-SDPReplicationStats {
    param(
        [parameter()]
        [Alias("LogicalIn")]
        [string] $logical_in,
        [parameter()]
        [Alias("LogicalOut")]
        [string] $logical_out,
        [parameter()]
        [Alias("PeerK2Name")]
        [string] $peer_k2_name,
        [parameter()]
        [Alias("PhysicalIn")]
        [string] $physical_in,
        [parameter()]
        [Alias("PhysicalOut")]
        [string] $physical_out,
        [parameter()]
        [int] $resolution,
        [parameter()]
        [int] $timestamp,
        [parameter()]
        [string] $volume,
        [parameter()]
        [Alias("VolumeName")]
        [string] $volume_name,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    $endpoint = "replication/stats/volumes"

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }
    return $results
}
