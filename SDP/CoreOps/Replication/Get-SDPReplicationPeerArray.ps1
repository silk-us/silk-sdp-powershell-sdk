function Get-SDPReplicationPeerArray {
    param(
        [parameter()]
        [Alias("BandwidthLimit")]
        [int] $bandwidth_limit,
        [parameter()]
        [Alias("CapacityAllocated")]
        [string] $capacity_allocated,
        [parameter()]
        [Alias("CapacityAllocatedSnapshotsAndViews")]
        [int] $capacity_allocated_snapshots_and_views,
        [parameter()]
        [Alias("CapacityAllocatedVolumes")]
        [string] $capacity_allocated_volumes,
        [parameter()]
        [Alias("CapacityFree")]
        [string] $capacity_free,
        [parameter()]
        [Alias("CapacityPhysical")]
        [string] $capacity_physical,
        [parameter()]
        [Alias("CapacityProvisioned")]
        [string] $capacity_provisioned,
        [parameter()]
        [Alias("CapacityProvisionedSnapshots")]
        [string] $capacity_provisioned_snapshots,
        [parameter()]
        [Alias("CapacityProvisionedViews")]
        [string] $capacity_provisioned_views,
        [parameter()]
        [Alias("CapacityProvisionedVolumes")]
        [string] $capacity_provisioned_volumes,
        [parameter()]
        [Alias("CapacityReserved")]
        [string] $capacity_reserved,
        [parameter()]
        [Alias("CapacityState")]
        [string] $capacity_state,
        [parameter()]
        [Alias("CapacityTotal")]
        [string] $capacity_total,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("LogicalBandwidthLimit")]
        [string] $logical_bandwidth_limit,
        [parameter()]
        [Alias("MgmtConnectivityState")]
        [string] $mgmt_connectivity_state,
        [parameter()]
        [Alias("MgmtHost")]
        [string] $mgmt_host,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("SystemId")]
        [int] $system_id,
        [parameter()]
        [string] $username,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "replication/peer_k2arrays"

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }
    return $results
}
