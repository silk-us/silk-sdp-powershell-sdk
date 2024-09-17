function Build-SDPPathFunctions {
    $pathFunction = @{}
    $pathFunction.add('volumes','Get-SDPVolume')
    $pathFunction.add('volume_groups','Get-SDPVolumeGroup')
    $pathFunction.add('hosts','Get-SDPHost')
    $pathFunction.add('host_groups','Get-SDPHostGroup')
    $pathFunction.add('snapshots','Get-SDPVolumeGroupSnapshot')
    $pathFunction.add('volsnaps','Get-SDPVolSnap')
    $pathFunction.add('retention_policies','Get-SDPRetentionPolicy')
    $pathFunction.add('mappings','Get-SDPHostMapping')
    $pathFunction.add('snapshot_scheduler','Get-SDPSnapshotScheduler')

    return $pathFunction
}

