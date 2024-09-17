# SDPVolumeThinClone

Function for generating a thin clone for a volume, 

## New-SDPVolumeThinClone
```PowerShell
New-SDPVolumeThinClone [-name] <string> [-volumeName] <string> [-volumeGroupName] <string> [-snapshotName] <string> [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory

* `-name` - [string] - Name for the resulting thin clone. 
* `-snapshotName` - [string] - Name for the existing snapshot. This should follow the volumegroup:snapshot naming convention. 
* `-volumeGroupName` - [string] - Name of the volume group that contains the volume you wish to clone. 
* `-volumeName` - [string] - Name of the volume that you wish to clone. 


Examples:

This creates a thin clone of `Volume01` named `ThinClone01` based on the existing snapshot named `Volumegroup01:Snapshot01`.

```PowerShell
New-SDPVolumeThinClone -name ThinClone01 -snapshotName 'Volumegroup01:Snapshot01' -volumeGroupName Volumegroup01 -volumeName Volume01
```

# Special note:

The remainder of thin clone management functions are conducted using the SDPVolume functions. 

Use `Get-SDPVolume` and `Remove-SDPVolume` to query for and delete snapshots created with `New-SDPVolumeThinClone`.
