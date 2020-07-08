function Get-SDPReplicationPeerVolumes {
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("LocalVolume")]
        [string] $local_volume,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("RemoteVolumeId")]
        [int] $remote_volume_id,
        [parameter()]
        [Alias("ReplicationPeerVolumeGroup")]
        [string] $replication_peer_volume_group,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "replication/peer_volumes"

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }
    return $results
}
