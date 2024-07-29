# SDPHostMapping

SDP host mapping functions.

## New-SDPHostMapping
```PowerShell
New-SDPHostMapping [-hostName] <string> [[-volumeName] <string>] [[-lun] <int>] [[-viewName] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-hostName` - [string] - Provide name for the desired host you wish to map. 

Optional
* `-volumeName` - [string] - Provide name for the desired volume you wish to map. 
* `-viewName` - [string] - Provide name for the desired snapshot view you wish to map.
* `-lun` - [int] - Configure a specific lun ID rather than letting the system use the next available. 

Examples:

Map a volume named `Volume01` to a host named `WinHost01`:

```PowerShell
New-SDPHostMapping -hostName WinHost01 -volumeName Volume01
```

Map a volume named `Volume01` to a host named `WinHost01` and enforce the use of Lun `3`:

```PowerShell
New-SDPHostMapping -hostName WinHost01 -volumeName Volume01 -Lun 3
```

## Set-SDPHostMapping
```PowerShell
Set-SDPHostMapping [-id] <string> [[-hostName] <string>] [[-lun] <int>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-id` - [string] - The desired mapping id. This can be infered via pipe. 

Optional
* `-hostName` - [string] - The desired host you wish to set this mapping to. 
* `-lun` - [int] - The desired lun you wish to enforce. 

Examples:

Move the mapping for the mapped id of `14` to `WinHost02`:

```PowerShell
Set-SDPHostMapping -id 14 -hostName WinHost02
```

Move all mappings for `WinHost01` to `WinHost02` via pipe:

```PowerShell
Get-SDPHostMapping -hostName WinHost01 | Set-SDPHostMapping -hostName WinHost02
```

## Get-SDPHostMapping
```PowerShell
Get-SDPHostMapping [[-hostName] <string>] [[-hostName] <int>] [[-lun] <int>] [[-unique_target] <bool>] [[-volumeName] <string>] [[-k2context] <string>] [-asSnapshot] [<CommonParameters>]
```

#### Parameters

Optional
* `-hostName` - [string] - The desired host you wish to query mappings for.  
* `-id` - [string] - The desired mapping id you wish to query the mapping for. 
* `-lun` - [int] - The desired lun id you wish to query mappings for. 
* `-volumeName` - [string] - The desired volume name you wish to query mappings for. 
* `-asSnapshot` - [switch] - Show mappings that are the result of snapshot view mappings. 
* `-unique_target` - [boolean] - Show mappings that have the `unique_target` value set for `true`.

Examples:

Show all host mappings:

```PowerShell
Get-SDPHostMapping
```

Show host mappings for host `WinHost01`:

```PowerShell
Get-SDPHostMapping -hostName WinHost01 
```

## Remove-SDPHostMapping
```PowerShell
Remove-SDPHostMapping [[-id] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-id` - [string] - Set the desired mapping id you wish to remove. This can be infered via pipe. 

Examples:

Remove mapping for the mapping id `14`:

```PowerShell
Remove-SDPHostMapping -id 14
```

Remove all host mappings for host `WinHost01`

```PowerShell
Get-SDPHostMapping -hostName WinHost01 Remove-SDPHostMapping
```