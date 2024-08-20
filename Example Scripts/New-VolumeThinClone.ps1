param(
    [parameter(Mandatory)]
    [string] $volumeName,
    [parameter(Mandatory)]
    [string] $volumeGroupName,
    [parameter(Mandatory)]
    [string] $targetHostName,
    [parameter(Mandatory)]
    [string] $snapshotName
)

<#
    .EXAMPLE
    New-VolumeThinClone.ps1 -volumeName volume01 -volumeGroupName VolumeGroup01 -targetHostName TestHost01 -snapshotName testwin01-vg:testsnap01

    This:
        - Creates a thin clone based on volume01.  
        - Auto-generates a datestamped clone name. 
        - Maps the thin clone to TestHost01. 
        
#>

# Check the snapshot, short name vs full name.

if ($snapshotName -notmatch ':') {
    $snapshotName = $volumeGroupName + ':' + $snapshotName
    $snap = Get-SDPVolumeGroupSnapshot -name $snapshotName
    if (!$snap) {
        $err = "No snapshot with the specified name exists: " + $snapshotName
        return $err | Write-Error 
    }
}

# Create the thin clone.

$cloneName = $volumeName + (get-date).ToString("yyyyMMddhhmmss").ToString()
$thinClone = New-SDPVolumeThinClone -name $cloneName -volumeName $volumeName -volumeGroupName $volumeGroupName -snapshotName $snapshotName

# Mount the thin clone to the specified host. 

New-SDPHostMapping -hostName $targethostName -volumeName $thinClone.name