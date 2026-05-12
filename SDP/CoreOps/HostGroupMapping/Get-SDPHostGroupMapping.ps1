<#
    SDPHostGroupMapping — typed wrapper for a host-group ↔ volume
    mapping. Same /mappings endpoint as host mappings, distinguished by
    whether `host.ref` matches /host_groups/.

    `host` and `volume` are ref-shaped; Update-SDPRefObjects attaches
    `host_name` and `volume_name` at runtime. Note that `host_name` here
    is actually a host_group name because of the polymorphic `host`
    field.
#>

class SDPHostGroupMapping {

    # --- Properties shown in the default table view ---
    [string]   $id
    [int]      $lun

    # --- Refs preserved for Update-SDPRefObjects to walk. ---
    [psobject] $host
    [psobject] $volume

    # Hidden context
    hidden [string] $context

    SDPHostGroupMapping() {}

    SDPHostGroupMapping([psobject] $apiHit, [string] $context) {
        $this.id        = $apiHit.id
        $this.lun       = $apiHit.lun
        $this.context = $context

        if ($apiHit.host)   { $this.host   = $apiHit.host }
        if ($apiHit.volume) { $this.volume = $apiHit.volume }
    }

    # ---- Operational methods --------------------------------------------

    [SDPHostGroupMapping] Refresh() {
        return [SDPHostGroupMapping]::new(
            (Get-SDPHostGroupMapping -id $this.id -context $this.context -doNotResolve),
            $this.context)
    }

    [void] Delete() {
        Remove-SDPHostGroupMapping -id $this.id -context $this.context | Out-Null
    }

    [string] ToString() {
        return "host_group_mapping/$($this.id) lun=$($this.lun)"
    }
}

Update-TypeData -TypeName 'SDPHostGroupMapping' `
                -DefaultDisplayPropertySet 'id','host_name','volume_name','lun' `
                -Force


<#
    .SYNOPSIS
    Returns host-group-to-volume mappings on the SDP.

    .DESCRIPTION
    All mappings (per-host AND per-host-group) live at the /mappings
    endpoint. This function returns only the host-group mappings —
    those whose `host.ref` matches /host_groups/.

    For per-host mappings see Get-SDPHostMapping.

    .PARAMETER hostGroupName
    Filter by host group name. Accepts piped input from Get-SDPHostGroup.

    .PARAMETER id
    The unique identifier of the mapping record.

    .PARAMETER lun
    Filter by LUN number.

    .PARAMETER unique_target
    Filter by unique-target flag.

    .PARAMETER volumeName
    Filter by volume name.

    .PARAMETER asSnapshot
    Limit results to mappings that expose a snapshot (rather than a
    volume).

    .PARAMETER doNotResolve
    Skip the auto-pipe through Update-SDPRefObjects.

    .PARAMETER context
    K2 context name. Defaults to 'sdpconnection'.

    .EXAMPLE
    Get-SDPHostGroupMapping -hostGroupName "HostGroup01"

    .EXAMPLE
    Get-SDPHostGroup -name "HostGroup01" | Get-SDPHostGroupMapping

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPHostGroupMapping {
    [CmdletBinding()]
    [OutputType([SDPHostGroupMapping])]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostGroupName,
        [parameter()]
        [int] $id,
        [parameter()]
        [int] $lun,
        [parameter()]
        [Alias("UniqueTarget")]
        [bool] $unique_target,
        [parameter()]
        [string] $volumeName,
        [parameter()]
        [switch] $asSnapshot,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = "mappings"
    }

    process {

        # parameter cleanup — strip internal-only switches before the URI build.
        if ($asSnapshot) {
            Write-Verbose 'removing asSnapshot from parameter list.'
            $PSBoundParameters.remove('asSnapshot') | Out-Null
        }
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        # special ops — resolve volumeName / hostGroupName to refs.

        if ($volumeName) {
            $volumeObj  = Get-SDPVolume -name $volumeName -context $context -doNotResolve
            $volumePath = ConvertTo-SDPObjectPrefix -ObjectPath "volumes" -ObjectID $volumeObj.id -nestedObject
            $PSBoundParameters.volume = $volumePath
            $PSBoundParameters.remove('volumeName') | Out-Null
        }

        if ($hostGroupName) {
            $hostGroupObj  = Get-SDPHostGroup -name $hostGroupName -context $context -doNotResolve
            $hostGroupPath = ConvertTo-SDPObjectPrefix -ObjectPath "host_groups" -ObjectID $hostGroupObj.id -nestedObject
            $PSBoundParameters.host = $hostGroupPath
            $PSBoundParameters.remove('hostGroupName') | Out-Null
        }

        # make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI

        if ($asSnapshot) {
            $results = $results | Where-Object { $_.volume -match '/snapshots/' }
        }

        # Filter to host-group mappings only (drop per-host mappings).
        $results = $results | Where-Object { $_.host.ref -match '/host_groups/' }

        $instances = foreach ($hit in $results) {
            [SDPHostGroupMapping]::new($hit, $context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -context $context
        }
    }
}
