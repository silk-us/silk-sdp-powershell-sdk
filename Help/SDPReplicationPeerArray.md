# SDPReplicationPeerArray

Functions for managing SDP replication peer arrays. 

## New-SDPReplicationPeerArray
```PowerShell
New-SDPReplicationPeerArray [-name] <string> [-mgmt_host] <string> [-localCredential] <pscredential> [-remoteCredential] <pscredential> [[-k2context] <string>] [<CommonParameters>]
```

### Special notes:

This function uses conventional PowerShell credential objects. You will need to generate a credential object such as:

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
* `-name` - [string] - The desired name for the peer configuration.
* `-localCredential` - [pscredential] - The local replication user credential that you wish to use.
* `-mgmt_host` - [string] - The remote peer management IP. The same IP you would use to manage the remote SDP. 
* `-remoteCredential` - [pscredential] - The remote replication user credential that you wish to use.

Examples:

This will create a peer named `ReplicationPeer01` using the credential `$replicationCreds` for both the local SDP and the remote SDP at the IP `10.21.0.4`

```PowerShell
New-SDPReplicationPeerArray -name ReplicationPeer01 -mgmt_host 10.21.0.4 -localCredential $replicationCreds -remoteCredential $replicationCreds
```

## Get-SDPReplicationPeerArray
```PowerShell
Get-SDPReplicationPeerArray [[-bandwidth_limit] <int>] [[-capacity_allocated] <string>] [[-capacity_allocated_snapshots_and_views] <int>] [[-capacity_allocated_volumes] <string>] [[-capacity_free] <string>] [[-capacity_physical] <string>] [[-capacity_provisioned] <string>] [[-capacity_provisioned_snapshots] <string>] [[-capacity_provisioned_views] <string>] [[-capacity_provisioned_volumes] <string>] [[-capacity_reserved] <string>] [[-capacity_state] <string>] [[-capacity_total] <string>] [[-id] <int>] [[-logical_bandwidth_limit] <string>] [[-mgmt_connectivity_state] <string>] [[-mgmt_host] <string>] [[-name] <string>] [[-system_id] <int>] [[-username] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Optional

This query supports the following parameter filters:

* `-bandwidth_limit` - [int] 
* `-capacity_allocated` - [string] 
* `-capacity_allocated_snapshots_and_views` - [int] 
* `-capacity_allocated_volumes` - [string] 
* `-capacity_free` - [string] 
* `-capacity_physical` - [string] 
* `-capacity_provisioned` - [string] 
* `-capacity_provisioned_snapshots` - [string] 
* `-capacity_provisioned_views` - [string] 
* `-capacity_provisioned_volumes` - [string] 
* `-capacity_reserved` - [string] 
* `-capacity_state` - [string] 
* `-capacity_total` - [string] 
* `-id` - [int] 
* `-logical_bandwidth_limit` - [string] 
* `-mgmt_connectivity_state` - [string] 
* `-mgmt_host` - [string] 
* `-name` - [string] 
* `-system_id` - [int] 
* `-username` - [string] 

Examples:

This returns the repliocation peer array named `ReplicationPeer01`:

```PowerShell
Get-SDPReplicationPeerArray -name ReplicationPeer01
```

## Remove-SDPReplicationPeerArray
```PowerShell
Remove-SDPReplicationPeerArray [[-id] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
Optional

* `-id` - [string] - The `id` of the peer array you wish to remove. This can be infered via pipe.


Examples:

Remove the SDP peer array witht he id of `4`. 

```PowerShell
Remove-SDPReplicationPeerArray -id 4
```

Remove the SDP peer array with the name `ReplicationPeer01` via pipe. 

```PowerShell
Get-SDPReplicationPeerArray -name ReplicationPeer01 | Remove-SDPReplicationPeerArray
```