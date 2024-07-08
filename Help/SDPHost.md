# SDPHost

## New-SDPHost

```PowerShell
New-SDPHost [[-hostGroupName] <string>] [[-hostGroupId] <string>] [-name] <string> [-type] {Linux | Windows | ESX} [[-connectivityType] {FC | NVME | iSCSI}] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-name` - [string] - Provide name for the SDP Host object. 
* `-type` - [string] - Decalre the host type (`Windows`, `Linux`, `ESX`)

Optional
* `-hostGroupName` - [string] - Set the host's host group via `name`. 
* `-hostGroupID` - [string] - Set the host's host group via `id`.
* `-connectivityType` - [string] - Set the desired host's connectivity type (Unused on Cloud SDP)

Examples:

Create a new host named `WinHost01` and set the host as a `Windows` host type. 
```PowerShell
New-SDPHost -name WinHost01 -type Windows
```
Create a new host named `SQLHost01` and add it to a host group named `SQLCluster01`
```PowerShell
New-SDPHost -name SQLHost01 -type Windows -hostGroupName SQLCluster01
```

## Set-SDPHost
```PowerShell
Set-SDPHost [-id] <string> [[-hostGroupName] <string>] [[-name] <string>] [[-type] {Linux | Windows | ESX}] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-id` - [string] - `id` value of the desired host. This can be piped via `Get-SDPHost`

Optional
* `-name` - [string] - Name value to set for the specified host. 
* `-type` - [string] - Decalre the host type (`Windows`, `Linux`, `ESX`)
* `-hostGroupName` - [string] - Set the host's host group via `name`. 
* `-hostGroupID` - [string] - Set the host's host group via `id`.

Examples:

Set values for a host with the `id` of `20`.
```PowerShell 
Set-SDPHost -id 20 -Name WinHost02
```
Rename a host named `WinHost01` to `WinHost02`. 
```PowerShell
Get-SDPHost -name WinHost01 | Set-SDPHost -name WinHost02
```
Change `WinHost01` to the `type` of `Linux`
```PowerShell
Get-SDPHost -name WinHost01 | Set-SDPHost -type Linux
```


## Get-SDPHost
```PowerShell
Get-SDPHost [[-name] <string>] [-host_group <string>] [-id <int>] [-type <string>] [-k2context <string>] [<CommonParameters>]
```

#### Parameters

Optional
* `-name` - [string] - Name value to set for the specified host.
* `-id` - [string] - `id` value of the desired host.  
* `-host_group` -[string] - Host group name that contains the desired host. 


Examples:

Get a list of all hosts.
```PowerShell
Get-SDPHost
```

Get the properties for a host named `WinHost01`
```PowerShell
Get-SDPHost -name WinHost01
```

## Remove-SDPHost
```PowerShell
Remove-SDPHost [[-name] <string>] [-id <string>] [-k2context <string>] [<CommonParameters>]
```

#### Parameters

optional
* `-name` - [string] - Name value to set for the specified host.
* `-id` - [string] - `id` value of the desired host.  

Examples:

Remove the host named `WinHost01`
```PowerShell
Remove-SDPHost -name WinHost01
```
Remove all members of a host group named `SQLCluster01`
```PowerShell
Get-SDPHostGroup -name SQLCluster01 | Get-SDPHost | Remove-SDPHost
```