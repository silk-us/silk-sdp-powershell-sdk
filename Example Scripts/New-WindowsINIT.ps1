param(
    [parameter(Mandatory)]
    [string] $Data1Interface,
    [parameter(Mandatory)]
    [string] $Data2Interface,
    [parameter()]
    [switch] $initialize
)
<#
    .SYNOPSIS
        This Script will automatically create and fullfill the iSCSI connection on any windows host by automatically querying the SDP data interfaces.

    .EXAMPLE
        New-WIndowsINIT.ps1 -Data1Interface Data1 -Data2Interface Data2
    
#>

Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI 

New-MSDSMSupportedHW –VendorID KMNRIO –Product KDP

$iSCSIData1 = Get-NetIPAddress -InterfaceAlias $Data1Interface -AddressFamily ipv4
$iSCSIData2 = Get-NetIPAddress -InterfaceAlias $Data2Interface -AddressFamily ipv4

$SDPIQN = Get-IscsiTarget

$dataPorts = Get-SDPSystemNetPorts | where-object {$_.name -match "data"}

foreach ($i in $dataPorts) {
    $portpath = '/system/net_ports/' + $i.id
    $currentInt = Get-SDPSystemNetIps | Where-Object {$_.net_port.ref -eq $portpath}
    if ($i.name -like "*01") {
        New-IscsiTargetPortal -TargetPortalAddress $currentInt.ip_address -TargetPortalPortNumber 3260 -InitiatorPortalAddress $iSCSIData1.IPAddress
        Connect-IscsiTarget -NodeAddress $SDPIQN.NodeAddress -TargetPortalAddress $currentInt.ip_address -TargetPortalPortNumber 3260 -InitiatorPortalAddress $iSCSIData1.IPAddress -IsPersistent $true -IsMultipathEnabled $true
    } elseif ($i.name -like "*02") {
        New-IscsiTargetPortal -TargetPortalAddress $currentInt.ip_address -TargetPortalPortNumber 3260 -InitiatorPortalAddress $iSCSIData2.IPAddress
        Connect-IscsiTarget -NodeAddress $SDPIQN.NodeAddress -TargetPortalAddress $currentInt.ip_address -TargetPortalPortNumber 3260 -InitiatorPortalAddress $iSCSIData2.IPAddress -IsPersistent $true -IsMultipathEnabled $true
    }
}

# Initiate those disks and put a ring on it. 

if ($initialize) {
    Get-Disk | Where-Object {$_.FriendlyName -like "KMNRIO*" -and $_.size -gt "262144"} | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "SDPVol" -Confirm:$false
}
