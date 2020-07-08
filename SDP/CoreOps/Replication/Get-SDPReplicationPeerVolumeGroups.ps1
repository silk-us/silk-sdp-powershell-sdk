function Get-SDPReplicationPeerVolumeGroups {
    param(
        [parameter()]
        [Alias("CapacityState")]
        [string] $capacity_state,
        [parameter()]
        [string] $fullname,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("LocalVolumeGroup")]
        [string] $local_volume_group,
        [parameter()]
        [Alias("LogicalCapacity")]
        [int] $logical_capacity,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("RemoteVolumeGroupId")]
        [int] $remote_volume_group_id,
        [parameter()]
        [Alias("ReplicationPeerK2array")]
        [string] $replication_peer_k2array,
        [parameter()]
        [Alias("ReplicationSession")]
        [string] $replication_session,
        [parameter()]
        [Alias("SnapshotsLogicalCapacity")]
        [int] $snapshots_logical_capacity,
        [parameter()]
        [Alias("VolumesLogicalCapacity")]
        [int] $volumes_logical_capacity,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "replication/peer_volume_groups"

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }
    return $results
}
