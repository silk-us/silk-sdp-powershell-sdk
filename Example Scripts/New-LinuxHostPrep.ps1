# Example Script for automated deployment of volumes using the SDP module. 

param(
    [parameter(mandatory)]
    [string] $name,
    [parameter(mandatory)]
    [int] $sizeInGB,
    [parameter(mandatory)]
    [int] $numberOfVolumes,
    [parameter()]
    [string] $iqn,
    [parameter()]
    [string] $pwwn
)

<#
    .EXAMPLE
    New-LinuxHostPrep.ps1 -name LinuxHost01 -sizeInGB 30 -numberOfVolumes 3 -pwwn 00:11:22:33:44:55:66:77

    This creates:
        - A Host Object named LinuxHost01 and assigns it the PWWN 00:11:22:33:44:55:66:77
        - A Volume Group named LinuxHost01-vg
        - 3 30GB volumes named LinuxHost01-vol-1 2 and 3 and adds them to the LinuxHost01-vg volume group
        - A mapping of each volume to the LinuxHost01 host object
#>

# Create the host
try {
    New-SDPHost -name $name -type Linux -verbose
} catch {
    Write-Error -Message "Host Creation failed"
}

# Create the volume group
$vgname = $name + '-vg'
New-SDPVolumeGroup -name $vgname -verbose

# Create the volumes
$number = 1
while ($number -le $numberOfVolumes) {
    $volname = $name + '-vol-' + $number
    New-SDPVolume -VolumeGroupName $vgname -sizeInGB $sizeInGB -name $volname -verbose
    New-SDPHostMapping -volumeName $volname -hostName $name -verbose
    $number++
}

# Add host connection information
if ($iqn) {Set-SDPHostIqn -iqn $iqn -hostName $name -verbose}
if ($pwwn) {Set-SDPHostPwwn -pwwn $pwwn -hostName $name -verbose}

Write-Host -ForegroundColor yellow '--- To remove all objects ---'
Write-Host -ForegroundColor yellow "Get-SDPHost -name $name | Get-SDPHostMapping | Remove-SDPHostMapping"
Write-Host -ForegroundColor yellow "Get-SDPHost -name $name | Remove-SDPHost"
Write-Host -ForegroundColor yellow "Get-SDPVolumeGroup -name $vgname | Get-SDPVolume | Remove-SDPVolume"
Write-Host -ForegroundColor yellow "Get-SDPVolumeGroup -name $vgname | Remove-SDPVolumeGroup"