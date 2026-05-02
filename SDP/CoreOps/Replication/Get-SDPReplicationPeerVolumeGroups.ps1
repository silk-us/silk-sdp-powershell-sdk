<#
    .SYNOPSIS
    Retrieves replication peer volume groups.

    .DESCRIPTION
    Queries the SDP for peer volume groups visible across configured
    replication sessions.

    .PARAMETER doNotResolve
    Skip ref-name resolution on the returned objects.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPReplicationPeerVolumeGroups

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPReplicationPeerVolumeGroups {
    [CmdletBinding()]
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
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "replication/peer_volume_groups"
    }

    process {

        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI |
            Add-SDPTypeName -TypeName 'SDPReplicationPeerVolumeGroup'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
