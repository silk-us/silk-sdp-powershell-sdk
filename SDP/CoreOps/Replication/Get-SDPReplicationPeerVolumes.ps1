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
        [switch] $doNotResolve,
        [parameter()]
        [string] $context = "sdpconnection"
    )

    $endpoint = "replication/peer_volumes"

    $PSBoundParameters.Remove('doNotResolve') | Out-Null

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -context $context -strictURI
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI
    }

    $results = $results | Add-SDPTypeName -TypeName 'SDPReplicationPeerVolume'

    if ($doNotResolve) {
        return $results
    }
    return ($results | Update-SDPRefObjects -context $context)
}
