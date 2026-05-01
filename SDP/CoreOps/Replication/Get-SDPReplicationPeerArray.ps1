<#
    .SYNOPSIS
    Retrieves replication peer arrays.

    .DESCRIPTION
    Queries the SDP for configured replication peer K2 arrays. All
    parameters are optional filters that map to API query fields.

    .PARAMETER doNotResolve
    Skip ref-name resolution on the returned objects.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPReplicationPeerArray

    .EXAMPLE
    Get-SDPReplicationPeerArray -name K2-5405

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPReplicationPeerArray {
    [CmdletBinding()]
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
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "replication/peer_k2arrays"
    }

    process {

        # Strip internal-only switches before passing to the URI builder.
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        # Query

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPReplicationPeerArray'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
