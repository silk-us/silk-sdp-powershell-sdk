param(
    [parameter(Mandatory)]
    [string] $volumeGroupName,
    [parameter(Mandatory)]
    [string] $targetHostName,
    [parameter(Mandatory)]
    [string] $snapshotName,
    [parameter(Mandatory)]
    [string] $retentionPolicyName
)

<#
    .EXAMPLE
    New-VolumeSnapshot.ps1 -volumeGroupName VolumeGroup01 -targetHostName TestHost01 -snapshotName testSnap -retentionPolicyName Backup

    This:
        - Creates a snapshot of the volume group VolumeGroup01 named testSnap using the Backup retention policy. 
        - Creates a view named testSnap-view. 
        - Maps the testSnap-view to the host TestHost01
#>

# Create the snapshot
New-SDPVolumeGroupSnapshot -name $snapshotName -volumeGroupName $volumeGroupName -retentionPolicyName $retentionPolicyName

# Create the View
$viewName = $snapshotName + '-view'
$fullSnapshotName = $volumeGroupName + ':' + $snapshotName
Get-SDPVolumeGroupSnapshot -name $fullSnapshotName | New-SDPVolumeView -name $viewName -retentionPolicyName $retentionPolicyName

# Mount the view
$fullSnapshotViewName = $volumeGroupName + ':' + $viewName
New-SDPHostMapping -hostName $targethostName -snapshotName $fullSnapshotViewName