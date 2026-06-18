function Build-SDPPathFunctions {
    $pathFunction = @{}

    # Core resources
    $pathFunction.add('volumes',           'Get-SDPVolume')
    $pathFunction.add('volume_groups',     'Get-SDPVolumeGroup')
    $pathFunction.add('hosts',             'Get-SDPHost')
    $pathFunction.add('host_groups',       'Get-SDPHostGroup')
    $pathFunction.add('snapshots',         'Get-SDPVolumeGroupSnapshot')
    $pathFunction.add('volsnaps',          'Get-SDPVolSnap')
    $pathFunction.add('retention_policies','Get-SDPRetentionPolicy')
    $pathFunction.add('mappings',          'Get-SDPHostMapping')
    $pathFunction.add('snapshot_scheduler','Get-SDPSnapshotScheduler')
    $pathFunction.add('host_fc_ports',     'Get-SDPHostFcPorts')
    $pathFunction.add('host_iqns',         'Get-SDPHostIqn')

    # Replication paths (refs from sessions, peer_volumes, etc.)
    $pathFunction.add('replication/peer_k2arrays',     'Get-SDPReplicationPeerArray')
    $pathFunction.add('replication/peer_volumes',      'Get-SDPReplicationPeerVolumes')
    $pathFunction.add('replication/peer_volume_groups','Get-SDPReplicationPeerVolumeGroups')
    $pathFunction.add('replication/peer_wan_ports',    'Get-SDPReplicationPeerWanPorts')
    $pathFunction.add('replication/sessions',          'Get-SDPReplicationSessions')
    $pathFunction.add('replication/rpo_history',       'Get-SDPReplicationRpoHistory')

    # System paths (refs from net_ips, fc_connection_mapper, etc.)
    $pathFunction.add('system/net_ports', 'Get-SDPSystemNetPorts')
    $pathFunction.add('system/fc_ports',  'Get-SDPSystemFcPorts')

    return $pathFunction
}
