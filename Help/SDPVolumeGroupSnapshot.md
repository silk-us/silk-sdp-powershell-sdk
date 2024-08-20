# SDPVolumeGroupSnapshot

SDP volume group snapshot functions. 

## New-SDPVolumeGroupSnapshot
```PowerShell
New-SDPVolumeGroupSnapshot [-name] <string> [-volumeGroupName] <string> [-retentionPolicyName] <string> [[-k2context] <string>] [-deletable] [-exposable] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-name` - [string] - The desired name for the snapshot. 
* `-retentionPolicyName` - [string] - The rentention policy assigned to the snapshot. 
* `-volumeGroupName` - [string] - The name of the volume group to snapshot. 

Optional

* `-deletable` - [switch] - Flag the snapshot as deletable. 
* `-exposable` - [switch] - Flag the snapshot as exposable. 

Examples:

Create local volume group snapshot named `Snapshot01` for volume group named `VolumeGroup01` using the retention policy `Backup`. 

```PowerShell
New-SDPVolumeGroupSnapshot -name Snapshot01 -volumeGroupName VolumeGroup01 -retentionPolicyName Backup
```

## Get-SDPVolumeGroupSnapshot
```PowerShell
Get-SDPVolumeGroupSnapshot [[-volumeGroupName] <string>] [[-description] <string>] [[-generation_number] <int>] [[-id] <int>] [[-iscsi_tgt_converted_name] <string>] [[-is_application_consistent] <bool>] [[-is_auto_deleteable] <bool>] [[-is_deleted] <bool>] [[-is_exist_on_peer] <bool>] [[-is_exposable] <bool>] [[-is_external] <bool>] [[-is_originating_from_peer] <bool>] [[-last_exposed_time] <string>] [[-name] <string>] [[-replication_session] <string>] [[-retention_policy] <string>] [[-short_name] <string>] [[-triggered_by] <string>] [[-volsnaps_provisioned_capacity] <int>] [[-volume_group] <string>] [[-wwn] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Optional
* `-name` - [string] - Filter snapshot(s) based on 
* `-volumeGroupName` - [string] - Filter snapshot(s) based on the specified volume group. 
* `-id` - [int] - Filter snapshot based on the snapshot id
* `-short_name` - [string] - Filter snapshot(s) based on the short name. This is the suffix part of `VolumeGroup01:Snapshot01`. The short name here would simply be `Snapshot01`
* `-description` - [string] - Filter snapshot(s) based on the description string. 
* `-generation_number` - [int] - Filter snapshot based on the generation number
* `-is_application_consistent` - [bool] - Filter snapshot(s) based on the `is_application_consistent` value. 
* `-is_auto_deleteable` - [bool] - Filter snapshot(s) based on the `is_auto_deleteable` value.
* `-is_deleted` - [bool] - Filter snapshot(s) based on deleted status. 
* `-is_exist_on_peer` - [bool] - Filter snapshot(s) based on the `is_exist_on_peer` value. 
* `-is_exposable` - [bool] - Filter snapshot(s) based that are flagged as exposable. 
* `-is_external` - [bool] - Filter snapshot(s) based on the `is_external` value. 
* `-is_originating_from_peer` - [bool] - Filter snapshot(s) that are sourced on a remote replication peer / session. 
* `-iscsi_tgt_converted_name` - [string] - Filter snapshot(s) based on the `iscsi_tgt_converted_name` value. 
* `-last_exposed_time` - [string] - Filter snapshot(s) based on the last exposed time. 
* `-replication_session` - [string] - Filter snapshot(s) based on the `replication_session` value. 
* `-retention_policy` - [string] - Filter snapshot(s) based on the `retention_policy` value. 
* `-triggered_by` - [string] - Filter snapshot(s) based on the `triggered_by` value. 
* `-volsnaps_provisioned_capacity` - [int] - Filter snapshot(s) based on the `volsnaps_provisioned_capacity` value. 

Examples:

This returns snapshots based on the specified volume group named `VolumeGroup01`

```PowerShell
Get-SDPVolumeGroupSnapshot -volumeGroupName VolumeGroup01
```

This returns snapshot named `VolumeGroup01:Snapshot01`

```PowerShell
Get-SDPVolumeGroupSnapshot -name VolumeGroup01:Snapshot01
```

## Remove-SDPVolumeGroupSnapshot
```PowerShell
Remove-SDPVolumeGroupSnapshot [-id] <string> [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Optional
* `-id` - [string] - text req = true

Examples:

Remove the volume group snapshot with the id of `23`. 

```PowerShell
Remove-SDPVolumeGroupSnapshot -id 23
```

Remove the volume group snapshot named `Snapshot01` via pipe. 

```PowerShell
Get-SDPVolumeGroupSnapshot -name Snapshot01 | Remove-SDPVolumeGroupSnapshot
```