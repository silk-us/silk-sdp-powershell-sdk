# SDPVolume

SDP volume functions.

## New-SDPVolume
```PowerShell
New-SDPVolume [-name] <string> [-sizeInGB] <int> [[-VolumeGroupName] <string>] [[-volumeGroupId] <string>] [[-Description] <string>] 
[[-k2context] <string>] [-VMWare] [-ReadOnly] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-name` - [string] - Provide the desired name for the volume. 
* `-sizeInGB` - [int] - Provide the desired size in GB (byte * 1024) for the volume. 

Optional
* `-volumeGroupName` - [string] - Provide desired existing volume group name in which to place the volume. 
* `-volumeGroupId` - [string] - Provide desired existing volume group id in which to place the volume. This can be inffered via pipe. 
* `-ReadOnly` - [switch] - Create the volume as read-only. 
* `-VMWare` - [switch] - Create the volume for use with VMWare vmfs. 
* `-Description` [string] - Set the description for the volume. 


Examples:

Create volume named `Volume01` and place it inside of the volume group `VolumeGroup01`:

```PowerShell
New-SDPVolume -name Volume01 -VolumeGroupName VolumeGroup01
```

Add a volume to an existing volume group via pipe:

```PowerShell
Get-SDPVolumeGroup -name VolumeGroup01 | New-SDPVolume -name Volume01
```

## Set-SDPVolume
```PowerShell
Set-SDPVolume [-id] <string> [[-name] <string>] [[-sizeInGB] <int>] [[-Description] <string>] [[-VolumeGroupName] <string>] [[-k2context] 
<string>] [-ReadOnly] [-ReadWrite] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-id` - [string] - The id of the volume you wish to modify. This can be inffered via pipe.

Optional
* `-name` - [string] - The desired name in which to rename the volume. 
* `-sizeInGB` - [int] - Provide the desired size in GB (byte * 1024) for the volume. This must be larger than the current volume size. 
* `-Description` [string] - Set the description for the volume. 
* `-ReadOnly` - [switch] - Set the volume for read-only.
* `-ReadWrite` - [switch] - Set the volume for read-write.

Examples:

Set a volume with the id of `17` to 4TB:

```PowerShell
Set-SDPVolume -id 17 -sizeInGB 4096
```

Rename a volume named `Volume01` to `Volume02` via pipe:

```PowerShell
Get-SDPVolume -name Volume01 | Set-SDPVolume -name Volume02
```


## Get-SDPVolume
```PowerShell
Get-SDPVolume [[-name] <string>] [-description <string>] [-id <int>] [-vmware_support <bool>] [-volume_group <string>] [-k2context <string>] [<CommonParameters>]
```

#### Parameters


Optional
* `-name` - [string] - Query for the desired volume name. 
* `-VolumeGroup` `-volume_group` - [string] - Query for the desired volume(s) conmtained in the specified volume group. 
* `-description` - [string] - Query for the desired volume that matches the description string. 
* `-id` - [int] - Query for the desired volume id. 
* `-VmwareSupport` `-vmware_support` - [bool] - Query for volume(s) that are configured with the VMWare flag. 

Examples:

Query for a volume named `Volume01`:

```PowerShell
Get-SDPVolume -name Volume01
```

Query for the volumes in volume group `VolumeGroup01`:

```PowerShell
Get-SDPVolume -VolumeGroup VolumeGroup01
```

## Remove-SDPVolume
```PowerShell
Remove-SDPVolume [[-id] <string>] [[-name] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Optional
* `-id` - [int] - The volume id you wish to remove. This can be infered via pipe. 
* `-name` - [string] - The volume name you wish to remove. 

Examples:

Remove the volume named `Volume01`:

```PowerShell
Remove-SDPVolume -name Volume01
```

Remove all volumes in the volume group `VolumeGroup01`:

```PowerShell
Get-SDPVolume -VolumeGroup VolumeGroup01 | Remove-SDPVolume
```