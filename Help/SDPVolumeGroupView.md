# SDPVolumeGroupView

Functions for managing volume group snapshot views. 

## New-SDPVolumeGroupView
```PowerShell
New-SDPVolumeGroupView [-name] <string> [-snapshotName] <string> [-retentionPolicyName] <string> [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory

* `-name` - [string] - text req = true
* `-retentionPolicyName` - [string] - text req = true
* `-snapshotName` - [string] - text req = true


Examples:

```PowerShell
Example
```

## Get-SDPVolumeGroupView
```PowerShell
Get-SDPVolumeGroupView [[-volumeGroupName] <string>] [[-description] <string>] [[-generation_number] <int>] [[-id] <int>] [[-iscsi_tgt_converted_name] <string>] [[-is_application_consistent] <bool>] [[-is_auto_deleteable] <bool>] [[-is_deleted] <bool>] [[-is_exist_on_peer] <bool>] [[-is_exposable] <bool>] [[-is_external] <bool>] [[-is_originating_from_peer] <bool>] [[-last_exposed_time] <string>] [[-name] <string>] [[-replication_session] <string>] [[-retention_policy] <string>] [[-short_name] <string>] [[-triggered_by] <string>] [[-volsnaps_provisioned_capacity] <int>] [[-volume_group] <string>] [[-wwn] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Optional

This query supports the following parameter filters:

* `-description` - [string] 
* `-generation_number` - [int] 
* `-id` - [int] 
* `-is_application_consistent` - [bool] 
* `-is_auto_deleteable` - [bool] 
* `-is_deleted` - [bool] 
* `-is_exist_on_peer` - [bool] 
* `-is_exposable` - [bool] 
* `-is_external` - [bool] 
* `-is_originating_from_peer` - [bool] 
* `-iscsi_tgt_converted_name` - [string] 
* `-last_exposed_time` - [string] 
* `-name` - [string] 
* `-replication_session` - [string] 
* `-retention_policy` - [string] 
* `-short_name` - [string] 
* `-triggered_by` - [string] 
* `-volsnaps_provisioned_capacity` - [int] 
* `-volumeGroupName` - [string] 
* `-volume_group` - [string] 
* `-wwn` - [string] 


Examples:

```PowerShell
Example
```

## Remove-SDPVolumeGroupView
```PowerShell
Remove-SDPVolumeGroupView [-id] <string> [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
Optional

* `-id` - [string] - text req = true


Examples:

```PowerShell
Example
```
