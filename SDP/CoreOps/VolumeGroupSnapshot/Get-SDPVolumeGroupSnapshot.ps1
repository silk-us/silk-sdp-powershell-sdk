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
        [string] $source,
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
        return $results
    }

}
