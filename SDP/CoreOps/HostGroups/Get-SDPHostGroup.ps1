<#
    SDPHostGroup — typed wrapper for a Silk SDP host group record.

    Lives co-located with Get-SDPHostGroup. Update-SDPRefObjects has
    nothing to attach for a top-level host group (no nested refs in the
    standard payload), but the class still carries hosts_count and
    volumes_count so the default table is informative.
#>

class SDPHostGroup {

    # --- Properties shown in the default table view ---
    [string]   $name
    [string]   $id
    [bool]     $allow_different_host_types
    [int]      $hosts_count
    [int]      $volumes_count

    # --- Identity (additional) ---
    [string]   $description
    [string]   $connectivity_type

    # Hidden context
    hidden [string] $k2context

    SDPHostGroup() {}

    SDPHostGroup([psobject] $apiHit, [string] $k2context) {
        $this.id                         = $apiHit.id
        $this.name                       = $apiHit.name
        $this.description                = $apiHit.description
        $this.connectivity_type          = $apiHit.connectivity_type
        $this.allow_different_host_types = [bool] $apiHit.allow_different_host_types
        $this.hosts_count                = $apiHit.hosts_count
        $this.volumes_count              = $apiHit.volumes_count
        $this.k2context                  = $k2context
    }

    # ---- Operational methods --------------------------------------------

    [SDPHostGroup] Refresh() {
        return [SDPHostGroup]::new(
            (Get-SDPHostGroup -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [void] Delete() {
        Remove-SDPHostGroup -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return $this.name
    }
}

Update-TypeData -TypeName 'SDPHostGroup' `
                -DefaultDisplayPropertySet 'name','id','allow_different_host_types','hosts_count','volumes_count' `
                -Force


<#
    .SYNOPSIS
    Use this function to query for Host Groups.

    .EXAMPLE
    Get-SDPHostGroup -name HostGroup01

    .DESCRIPTION
    Query for any host group defined on the desired SDP.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPHostGroup {
    [CmdletBinding()]
    [OutputType([SDPHostGroup])]
    param(
        [parameter()]
        [int] $id,
        [parameter(position=1)]
        [string] $name,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "host_groups"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        $instances = foreach ($hit in $results) {
            [SDPHostGroup]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
