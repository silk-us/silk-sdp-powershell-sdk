<#
    SDPVgCapacityPolicy — typed wrapper for a Silk SDP volume group
    capacity policy.

    Lives co-located with Get-SDPVgCapacityPolicy. A capacity policy is
    a flat set of percent thresholds (warning / error / critical / full
    / snapshot overhead) plus an optional snapshot count. There are no
    ref-shaped properties on this resource.
#>

class SDPVgCapacityPolicy {

    # --- Properties shown in the default table view ---
    [string] $name
    [string] $id
    [int]    $full_threshold
    [int]    $warning_threshold
    [int]    $error_threshold
    [int]    $critical_threshold

    # --- Additional properties ---
    [int]    $snapshot_overhead_threshold
    [int]    $num_snapshots
    [bool]   $is_default

    # Hidden context for instance-method calls.
    hidden [string] $k2context

    SDPVgCapacityPolicy() {}

    SDPVgCapacityPolicy([psobject] $apiHit, [string] $k2context) {
        $this.id                          = $apiHit.id
        $this.name                        = $apiHit.name
        $this.full_threshold              = $apiHit.full_threshold
        $this.warning_threshold           = $apiHit.warning_threshold
        $this.error_threshold             = $apiHit.error_threshold
        $this.critical_threshold          = $apiHit.critical_threshold
        $this.snapshot_overhead_threshold = $apiHit.snapshot_overhead_threshold
        $this.num_snapshots               = $apiHit.num_snapshots
        $this.is_default                  = [bool] $apiHit.is_default
        $this.k2context                   = $k2context
    }

    # ---- Operational methods --------------------------------------------

    [SDPVgCapacityPolicy] Refresh() {
        return [SDPVgCapacityPolicy]::new(
            (Get-SDPVgCapacityPolicy -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [void] Delete() {
        Remove-SDPVgCapacityPolicy -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return $this.name
    }
}

Update-TypeData -TypeName 'SDPVgCapacityPolicy' `
                -DefaultDisplayPropertySet 'name','id','full_threshold','warning_threshold','error_threshold','critical_threshold' `
                -Force


<#
    .SYNOPSIS
    Retrieves volume group capacity policies from the SDP.

    .DESCRIPTION
    Queries for capacity policies on the Silk Data Pod. Capacity
    policies define warning / error / critical / full thresholds for
    volume groups and an optional snapshot retention count. Returns
    SDPVgCapacityPolicy instances that render as a narrow table by
    default and expose Refresh / Delete methods.

    .PARAMETER critical_threshold
    Filter by critical threshold percent.

    .PARAMETER error_threshold
    Filter by error threshold percent.

    .PARAMETER full_threshold
    Filter by full threshold percent.

    .PARAMETER id
    The unique identifier of the capacity policy.

    .PARAMETER is_default
    Filter by the default-policy flag.

    .PARAMETER name
    The name of the capacity policy to retrieve.

    .PARAMETER num_snapshots
    Filter by number of snapshots.

    .PARAMETER snapshot_overhead_threshold
    Filter by snapshot overhead threshold percent.

    .PARAMETER warning_threshold
    Filter by warning threshold percent.

    .PARAMETER doNotResolve
    Skip the auto-pipe through Update-SDPRefObjects. Returns raw API
    objects (no class wrapping).

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Get-SDPVgCapacityPolicy
    Retrieves all capacity policies from the SDP.

    .EXAMPLE
    Get-SDPVgCapacityPolicy -name "Policy01"

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPVgCapacityPolicy {
    [CmdletBinding()]
    [OutputType([SDPVgCapacityPolicy])]
    param(
        [parameter()]
        [Alias("CriticalThreshold")]
        [int] $critical_threshold,
        [parameter()]
        [Alias("ErrorThreshold")]
        [int] $error_threshold,
        [parameter()]
        [Alias("FullThreshold")]
        [int] $full_threshold,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IsDefault")]
        [bool] $is_default,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("NumSnapshots")]
        [int] $num_snapshots,
        [parameter()]
        [Alias("SnapshotOverheadThreshold")]
        [int] $snapshot_overhead_threshold,
        [parameter()]
        [Alias("WarningThreshold")]
        [int] $warning_threshold,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "vg_capacity_policies"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        $instances = foreach ($hit in $results) {
            [SDPVgCapacityPolicy]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
