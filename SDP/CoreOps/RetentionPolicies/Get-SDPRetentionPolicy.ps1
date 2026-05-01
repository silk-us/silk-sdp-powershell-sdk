<#
    SDPRetentionPolicy — typed wrapper for a Silk SDP retention policy.

    Lives co-located with Get-SDPRetentionPolicy so the type, the default
    rendering setup, and the cmdlet that emits instances are all one
    click apart.

    Retention policies define how long snapshots are kept before being
    automatically deleted. The hit shape is small and flat — there are
    no ref-shaped properties on this resource — so Update-SDPRefObjects
    is a no-op for these objects, but we still flow through it for
    consistency.
#>

class SDPRetentionPolicy {

    # --- Properties shown in the default table view ---
    [string] $name
    [string] $id
    [int]    $num_snapshots
    [int]    $weeks
    [int]    $days
    [int]    $hours

    # Hidden context for instance-method calls.
    hidden [string] $k2context

    SDPRetentionPolicy() {}

    SDPRetentionPolicy([psobject] $apiHit, [string] $k2context) {
        $this.id            = $apiHit.id
        $this.name          = $apiHit.name
        $this.num_snapshots = $apiHit.num_snapshots
        $this.weeks         = $apiHit.weeks
        $this.days          = $apiHit.days
        $this.hours         = $apiHit.hours
        $this.k2context     = $k2context
    }

    # ---- Operational methods --------------------------------------------

    [SDPRetentionPolicy] Refresh() {
        return [SDPRetentionPolicy]::new(
            (Get-SDPRetentionPolicy -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [void] Delete() {
        Remove-SDPRetentionPolicy -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return $this.name
    }
}

Update-TypeData -TypeName 'SDPRetentionPolicy' `
                -DefaultDisplayPropertySet 'name','id','num_snapshots','weeks','days','hours' `
                -Force


<#
    .SYNOPSIS
    Retrieves retention policies from the SDP.

    .DESCRIPTION
    Queries for snapshot retention policies on the Silk Data Pod.
    Retention policies define how long snapshots are kept before
    automatic deletion. Returns SDPRetentionPolicy instances that render
    as a narrow table by default and expose Refresh / Delete methods.

    .PARAMETER id
    The unique identifier of the retention policy.

    .PARAMETER name
    The name of the retention policy to retrieve.

    .PARAMETER doNotResolve
    Skip the auto-pipe through Update-SDPRefObjects. Returns raw API
    objects (no class wrapping).

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Get-SDPRetentionPolicy
    Retrieves all retention policies from the SDP.

    .EXAMPLE
    Get-SDPRetentionPolicy -name "Policy01"
    Retrieves the retention policy named "Policy01".

    .EXAMPLE
    Get-SDPRetentionPolicy -id 5
    Retrieves the retention policy with ID 5.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPRetentionPolicy {
    [CmdletBinding()]
    [OutputType([SDPRetentionPolicy])]
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "retention_policies"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        $instances = foreach ($hit in $results) {
            [SDPRetentionPolicy]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
