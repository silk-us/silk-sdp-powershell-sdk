<#
    .SYNOPSIS
    Retrieves volume group snapshots from the SDP.

    .DESCRIPTION
    Queries for volume group snapshots on the Silk Data Pod. Volume group snapshots are point-in-time copies of all volumes in a volume group.

    .PARAMETER volumeGroupName
    Filter snapshots by volume group name. Accepts piped input from Get-SDPVolumeGroup.

    .PARAMETER description
    Filter snapshots by description text.

    .PARAMETER generation_number
    Filter by generation number of the snapshot.

    .PARAMETER id
    The unique identifier of the snapshot.

    .PARAMETER iscsi_tgt_converted_name
    Filter by iSCSI target converted name.

    .PARAMETER is_application_consistent
    Filter by application consistency flag.

    .PARAMETER is_auto_deleteable
    Filter by auto-deleteable flag.

    .PARAMETER is_deleted
    Include deleted snapshots in results.

    .PARAMETER is_exist_on_peer
    Filter by existence on replication peer.

    .PARAMETER is_exposable
    Filter by exposable flag.

    .PARAMETER is_external
    Filter by external snapshot flag.

    .PARAMETER is_originating_from_peer
    Filter by snapshots originating from replication peer.

    .PARAMETER last_exposed_time
    Filter by last time snapshot was exposed.

    .PARAMETER name
    The name of the snapshot to retrieve.

    .PARAMETER replication_session
    Filter by replication session.

    .PARAMETER retention_policy
    Filter by retention policy name.

    .PARAMETER short_name
    Filter by short name of the snapshot.

    .PARAMETER triggered_by
    Filter by what triggered the snapshot (manual, scheduled, replication).

    .PARAMETER volsnaps_provisioned_capacity
    Filter by provisioned capacity.

    .PARAMETER volume_group
    Filter by volume group reference.

    .PARAMETER wwn
    Filter by World Wide Name.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolumeGroupSnapshot
    Retrieves all volume group snapshots from the SDP.

    .EXAMPLE
    Get-SDPVolumeGroupSnapshot -name "VG01-Snap01"
    Retrieves the snapshot named "VG01-Snap01".

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01" | Get-SDPVolumeGroupSnapshot
    Retrieves all snapshots for volume group "VG01".

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Get-SDPVolumeGroupSnapshot {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias("pipeName")]
        [string] $volumeGroupName,
        [parameter()]
        [string] $description,
        [parameter()]
        [Alias("GenerationNumber")]
        [int] $generation_number,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IscsiTgtConvertedName")]
        [string] $iscsi_tgt_converted_name,
        [parameter()]
        [Alias("IsApplicationConsistent")]
        [bool] $is_application_consistent,
        [parameter()]
        [Alias("IsAutoDeleteable")]
        [bool] $is_auto_deleteable,
        [parameter()]
        [Alias("IsDeleted")]
        [bool] $is_deleted,
        [parameter()]
        [Alias("IsExistOnPeer")]
        [bool] $is_exist_on_peer,
        [parameter()]
        [Alias("IsExposable")]
        [bool] $is_exposable,
        [parameter()]
        [Alias("IsExternal")]
        [bool] $is_external,
        [parameter()]
        [Alias("IsOriginatingFromPeer")]
        [bool] $is_originating_from_peer,
        [parameter()]
        [Alias("LastExposedTime")]
        [string] $last_exposed_time,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("ReplicationSession")]
        [string] $replication_session,
        [parameter()]
        [Alias("RetentionPolicy")]
        [string] $retention_policy,
        [parameter()]
        [Alias("ShortName")]
        [string] $short_name,
        [parameter()]
        [Alias("TriggeredBy")]
        [string] $triggered_by,
        [parameter()]
        [Alias("VolsnapsProvisionedCapacity")]
        [int] $volsnaps_provisioned_capacity,
        [parameter()]
        [Alias("VolumeGroup")]
        [string] $volume_group,
        [parameter()]
        [string] $wwn,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    begin {
        $endpoint = "snapshots"
    }
    
    process {
        if ($volumeGroupName) {
            $volumeGroupid = Get-SDPVolumeGroup -name $volumeGroupName -k2context $k2context
            $volumeGroupPath = ConvertTo-SDPObjectPrefix -ObjectID $volumeGroupid.id -ObjectPath 'volume_groups' -nestedObject
            $PSBoundParameters.remove('volumeGroupName') | Out-Null
            $PSBoundParameters.volume_group = $volumeGroupPath
        }

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        $newResults = @()
        foreach ($r in $results) {  
            $ref = ConvertFrom-SDPObjectPrefix -Object $r.source
            if ($ref.ObjectPath -eq 'volume_groups') {
                $newResults += $r
            }
        }
        return $newResults
    }

}
