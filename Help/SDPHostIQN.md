# SDPHostIQN

SDP Host IQN management functions. 

## Set-SDPHostIQN
```PowerShell
Set-SDPHostIqn [-hostName] <string> [-iqn] <string> [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Mandatory
* `-hostName` - [string] - Name of the desired host for which you want to assign an IQN. 
* `-iqn` - [string] - The IQN for which you want to set for the desired host. 


Examples:
Set The IQN for a host named `WinHost01`

```PowerShell
Set-SDPHostIQN -hostName WinHost01 -iqn iqn.1991-05.com.microsoft:winhost01
```


## Get-SDPHostIQN
```PowerShell
Get-SDPHostIqn [[-hostName] <string>] [[-id] <int>] [[-iqn] <string>] [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Optional
* `-hostName` - [string] - The desired host for which you want to query the asigned IQN. 
* `-id` - [int] - The ID for the IQN you wish to query for.
* `-iqn` - [string] - The literal IQN string you wish to query for. 

Examples:
Query for the IQN for the host WinHost01. 
```PowerShell
Get-SDPHostIQN -hostName WinHost01
```

Query for the IQN for the host `WinHost01` via pipe. 
```PowerShell
Get-SDPHost -name WinHost01 | Get-SDPHostIQN
```

## Remove-SDPHostIQN
```PowerShell
Remove-SDPHostIqn [-hostName] <string> [[-k2context] <string>] [<CommonParameters>]
```

#### Parameters

Optional
* `-hostName` - [string] - The desired host for which you want to remove an assigned IQN.  

Examples:
Removes any IQN assigned to the host `WinHost01`
```PowerShell
Remove-SDPHostIQN -hostName WinHost01
```

Removes any IQN assigned to the host `WinHost01 via pipe`
```PowerShell
Get-SDPHost -name WinHost01 | Remove-SDPHostIQN 
```