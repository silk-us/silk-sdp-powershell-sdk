# SDPReplicationVolumeGroupSnapshot

Singular function for creating volume group snapshots within a replication session context. 

## New-SDPReplicationVolumeGroupSnapshot
```PowerShell
New-SDPReplicationVolumeGroupSnapshot [-volumeGroupName] <string> [-replicationSession] <string> [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory

* `-replicationSession` - [string] - Specify the replication session by name for the snapshot request
* `-volumeGroupName` - [string] - Set the volume group by name for the snapshot request. 


Examples:

Create a snapshot for the Volume Group SQLHost01-vg against the replication session named sqlhosr01-rep

```PowerShell
New-SDPReplicationVolumeGroupSnapshot -volumeGroupName SQLHost01-vg -replicationSession sqlhost01-rep
```

# Special note:

The remainder of snapshot management functions are conducted using the SDPVolumeGroupSnapshot functions. 

Use `Get-SDPVolumeGroupSnapshot` and `Remove-SDPVolumeGroupSnapshot` to query for and delete snapshots created with `New-SDPReplicationVolumeGroupSnapshot`.