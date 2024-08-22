# SDPReplicationPeerArray

Functions for managing SDP replication peer arrays. 

## New-SDPReplicationPeerArray
```PowerShell
New-SDPReplicationPeerArray [-name] <string> [-mgmt_host] <string> [-localCredential] <pscredential> [-remoteCredential] <pscredential> [[-k2context] <string>] [<CommonParameters>]
```

## Special notes:

This function uses convenetional PowerShell credential objects. You will need to generate a creential object such as:

```PowerShell
$replicationCreds = Get-Credential
```
or:

```PowerShell
$user = 'replication'
$password = 'P@ssw0rd123' # as an example

[securestring]$passwordString = ConvertTo-SecureString $password -AsPlainText -Force
[pscredential]$replicationCreds = New-Object System.Management.Automation.PSCredential ($user, $passwordStringd)
```
#### Parameters

Mandatory
Optional

* `-localCredential` - [pscredential] - text req = true
* `-mgmt_host` - [string] - text req = true
* `-name` - [string] - text req = true
* `-remoteCredential` - [pscredential] - text req = true


Examples:

```PowerShell
Example
```

## Set-SDPReplicationPeerArray
```PowerShell
_SETCMD
```

#### Parameters

Mandatory
Optional

* `-localCredential` - [pscredential] - text req = true
* `-mgmt_host` - [string] - text req = true
* `-name` - [string] - text req = true
* `-remoteCredential` - [pscredential] - text req = true


Examples:

```PowerShell
Example
```

## Get-SDPReplicationPeerArray
```PowerShell
Get-SDPReplicationPeerArray [[-bandwidth_limit] <int>] [[-capacity_allocated] <string>] [[-capacity_allocated_snapshots_and_views] <int>] [[-capacity_allocated_volumes] <string>] [[-capacity_free] <string>] [[-capacity_physical] <string>] [[-capacity_provisioned] <string>] [[-capacity_provisioned_snapshots] <string>] [[-capacity_provisioned_views] <string>] [[-capacity_provisioned_volumes] <string>] [[-capacity_reserved] <string>] [[-capacity_state] <string>] [[-capacity_total] <string>] [[-id] <int>] [[-logical_bandwidth_limit] <string>] [[-mgmt_connectivity_state] <string>] [[-mgmt_host] <string>] [[-name] <string>] [[-system_id] <int>] [[-username] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
Optional

* `-bandwidth_limit` - [int] - text req = false
* `-capacity_allocated` - [string] - text req = false
* `-capacity_allocated_snapshots_and_views` - [int] - text req = false
* `-capacity_allocated_volumes` - [string] - text req = false
* `-capacity_free` - [string] - text req = false
* `-capacity_physical` - [string] - text req = false
* `-capacity_provisioned` - [string] - text req = false
* `-capacity_provisioned_snapshots` - [string] - text req = false
* `-capacity_provisioned_views` - [string] - text req = false
* `-capacity_provisioned_volumes` - [string] - text req = false
* `-capacity_reserved` - [string] - text req = false
* `-capacity_state` - [string] - text req = false
* `-capacity_total` - [string] - text req = false
* `-id` - [int] - text req = false
* `-logical_bandwidth_limit` - [string] - text req = false
* `-mgmt_connectivity_state` - [string] - text req = false
* `-mgmt_host` - [string] - text req = false
* `-name` - [string] - text req = false
* `-system_id` - [int] - text req = false
* `-username` - [string] - text req = false


Examples:

```PowerShell
Example
```

## Remove-SDPReplicationPeerArray
```PowerShell
Remove-SDPReplicationPeerArray [[-id] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
Optional

* `-id` - [string] - text req = false


Examples:

```PowerShell
Example
```
