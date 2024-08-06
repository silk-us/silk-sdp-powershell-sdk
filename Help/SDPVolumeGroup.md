# SDPVolumeGroup

SDP volume group functions

## New-SDPVolumeGroup
```PowerShell
New-SDPVolumeGroup [-name] <string> [[-quotaInGB] <int>] [[-Description] <string>] [[-capacityPolicy] <string>] [[-k2context] <string>] [-enableDeDuplication] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-name` - [string] - Desired name for the volume group.

Optional
* `-Description` - [string] - Desired description  for the volume group. 
* `-capacityPolicy` - [string] - Desired capacity policy name to associate with this volume group. 
* `-enableDeDuplication` - [switch] - Enable deduplication for the volume group. 
* `-quotaInGB` - [int] - Quota for the volume group (in GB)

Examples:

Create a volume group named `VolumeGroup01`:

```PowerShell
New-SDPVolumeGroup -name VolumeGroup01
```

Create a volume group named `VolumeGroup01` with a 4TB quota:

```PowerShell
New-SDPVolumeGroup -name VolumeGroup01 -quotaInGB 4096
```

## Set-SDPVolumeGroup
```PowerShell
Set-SDPVolumeGroup [[-id] <array>] [[-name] <string>] [[-quotaInGB] <int>] [[-enableDeDuplication] <bool>] [[-Description] <string>] [[-capacityPolicy] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters
Mandatory
* `-id` - [int] - `id` of the volume group you wish to modify. Can be inferred via pipe. 

Optional
* `-Description` - [string] - Desired description string for the volume group. 
* `-capacityPolicy` - [string] - Specified capacity poly name to assign to the volume group. 
* `-enableDeDuplication` - [bool] - Enables or disables deduplication for the volume group
* `-name` - [string] - Desired name for the volume group. 
* `-quotaInGB` - [int] - Quota for the volume group specified in GB (bytes * 1024).

Examples:

Enable dedplication for the volume group with the id of `14`:

```PowerShell
Set-SDPVolumeGroup -id 14 -enableDeDeplication $true
```

Rename volume group `VolumeGroup01` to `VolumeGroup02` via pipe:

```PowerShell
Get-SDPVolumeGroup -name VolumeGroup01 | Set-SDPVolumeGroup -name VolumeGroup02
```

## Get-SDPVolumeGroup
```PowerShell
Get-SDPVolumeGroup [[-name] <string>] [-capacity_state <string>] [-description <string>] [-id <int>] [-replication_peer_volume_group <string>] [-k2context <string>] [<CommonParameters>]
```

#### Parameters

Optional
* `-CapacityState` `-capacity_state` - [string] - Filter for the specified capacity state. 
* `-description` - [string] - Filter by the specified description. 
* `-id` - [int] - Filter for the specified id. 
* `-name` - [string] - Filter for the specified name. 
* `-ReplicationPeerVolumeGroup` `-replication_peer_volume_group` - [string] - Filter for the specified replication peer volume group name. 

Examples:

List the volume group named `VolumeGroup01`:

```PowerShell
Get-SDPVolumeGroup -name VolumeGroup01
```

List volume groups with an `ok` capacity_state:

```PowerShell
Get-SDPVolumeGroup -CapacityState ok
```

## Remove-SDPVolumeGroup
```PowerShell
Remove-SDPVolumeGroup [[-id] <string>] [[-name] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Optional
* `-id` - [string] - text req = false
* `-name` - [string] - text req = false

Examples:

Remove volume group with the id `14`

```PowerShell
Remove-SDPVolumeGroup -id 14
```

Remove volume group named `VolumeGroup01` via pipe:

```PowerShell
Get-SDPVolumeGroup -name VolumeGroup01 | Remove-SDPVolumeGroup 
```