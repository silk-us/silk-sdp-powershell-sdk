# Silk Data Pod (formerly Kaminario K2) PowerShell SDK 
## This SDK and module, though nearly feature complete, is still pre-release and undergoing development. 

### Installation 
For now, clone this repo and import the module manually via:
```powershell
Import-Module ./path/SDP/sdp.psd1
```

Or install via the PowerShell Gallery
```powershell
Find-Module SDP | Install-Module -confirm:0
```

Or, run the provided InstallSDP.ps1 script. 
```powershell
Unblock-File .\InstallSDP.ps1
.\InstallSDP.ps1
```
Which gives you a simple install menu. 
```powershell
------
1. C:\Users\user\Documents\PowerShell\Modules
2. C:\Program Files\PowerShell\Modules
3. c:\program files\powershell\7\Modules
4. C:\Program Files (x86)\WindowsPowerShell\Modules
5. C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
------
Select Install location:
```

### Example usage: 

This module requires Powershell 4.x or above and was developed on PowerShell Core Preview 7. 
After importing, you can connect to the Silk Data Platform or Kaminario K2 appliance using a conventional PowerShell credential object
```powershell
$creds = get-credential
Connect-SDP -Server 10.10.47.15 -Credentials $cred
```

You can then use the functions in the module manifest to perform the desired operations. 
```Powershell
# Gather events specific to the desired query:
Get-SDPEvents -EventId 28 -user admin

# Quickly gather the hosts for a desired host group:
Get-SDPHostGroup -name TestDemo | Get-SDPHost

# Create Host:
New-SDPHost -name Host01 -type Linux

# Create Volume Group:
New-SDPVolumeGroup -name VG01

# Create Volumes and add volumes to volume group:
New-SDPVolume -name Vol01 -sizeInGB 20 -volumeGroupname VG01
# or via pipe
Get-SDPVolumeGroup -name VG01 | New-SDPVolume -name Vol02 -sizeInGB 20

# Move volumes from VolumeGroup VG01 to VG02:
Get-SDPVolumeGroup -name VG01 | Get-SDPVolume | Set-SDPVolume -volumeGroupName VG02

# Add all volumes from a volume group to a host:
Get-SDPVolumeGroup -name VG01 | Get-SDPVolume | New-SDPHostMapping -hostName Host01
```

Specify -Verbose on any cmdlet to see the entire API process, including endoint declarations, and json statements. You can use this to help model API calls directly or troubleshoot. 
