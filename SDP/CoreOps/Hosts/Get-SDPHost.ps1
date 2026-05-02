<#
    SDPHost — typed wrapper for a Silk SDP host record.

    Lives co-located with Get-SDPHost. Defined now so it's available to
    callers that want to construct hosts from raw API hits; Get-SDPHost
    itself still returns raw objects until you flip the emit (one-line
    change at the bottom of this file).
#>

class SDPHost {

    # --- Properties shown in the default table view ---
    # `host_group_name` is intentionally NOT declared as a class property —
    # Update-SDPRefObjects attaches it as a NoteProperty at runtime.
    # Declaring it here would conflict with that Add-Member call.
    [string]   $name
    [string]   $id
    [string]   $type
    [int]      $volumes_count

    # --- Identity (additional) ---
    # Stored as the original nested ref object (e.g. @{ref="/host_groups/4"})
    # so `| Update-SDPRefObjects` can walk it. Do not flatten.
    [psobject] $host_group
    [bool]     $is_part_of_group
    [int]      $views_count

    # Hidden context
    hidden [string] $k2context

    SDPHost() {}

    SDPHost([psobject] $apiHit, [string] $k2context) {
        $this.id               = $apiHit.id
        $this.name             = $apiHit.name
        $this.type             = $apiHit.type
        $this.is_part_of_group = [bool] $apiHit.is_part_of_group
        $this.views_count      = $apiHit.views_count
        $this.volumes_count    = $apiHit.volumes_count
        $this.k2context        = $k2context

        if ($apiHit.host_group) {
            $this.host_group = $apiHit.host_group
        }
    }

    # ---- Operational methods --------------------------------------------

    [void] MapVolume([string] $volumeName) {
        New-SDPHostMapping -hostName $this.name -volumeName $volumeName -k2context $this.k2context | Out-Null
    }

    [void] UnmapVolume([string] $volumeName) {
        Get-SDPHostMapping -hostName $this.name -volumeName $volumeName -k2context $this.k2context |
            Remove-SDPHostMapping -k2context $this.k2context | Out-Null
    }

    [SDPHost] AssignToGroup([string] $hostGroupName) {
        Set-SDPHost -id $this.id -hostGroupName $hostGroupName -k2context $this.k2context | Out-Null
        return $this.Refresh()
    }

    [SDPHost] Refresh() {
        # Mutate $this in place so callers' existing references stay current.
        $fresh = Get-SDPHost -id $this.id -k2context $this.k2context
        foreach ($p in $fresh.PSObject.Properties) {
            if ($this.PSObject.Properties[$p.Name]) {
                $this.($p.Name) = $p.Value
            } else {
                Add-Member -InputObject $this -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force
            }
        }
        return $this
    }

    [void] Delete() {
        Remove-SDPHost -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return "$($this.name) [$($this.type)]"
    }
}

Update-TypeData -TypeName 'SDPHost' `
                -DefaultDisplayPropertySet 'name','id','type','host_group_name','volumes_count' `
                -Force


<#
    .SYNOPSIS
    Retrieves host information from the SDP.

    .DESCRIPTION
    Queries for existing host records on the Silk Data Pod. Can filter by
    name, ID, type, or host group.

    .PARAMETER name
    The name of the host to retrieve.

    .PARAMETER id
    The unique identifier of the host.

    .PARAMETER type
    Filter by host type (Linux, Windows, ESX, AIX, Solaris).

    .PARAMETER host_group
    Filter hosts by host group name or ID. Accepts piped input from
    Get-SDPHostGroup.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Get-SDPHost
    Retrieves all hosts from the SDP.

    .EXAMPLE
    Get-SDPHost -name WinHost01
    Retrieves the host named "WinHost01".

    .EXAMPLE
    Get-SDPHostGroup -name SQLCluster | Get-SDPHost
    Retrieves all hosts in the SQLCluster host group.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPHost {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [Alias("hostGroup")]
        [string] $host_group,
        [parameter()]
        [int] $id,
        [parameter(Position=1)]
        [ValidateLength(0, 32)]
        [string] $name,
        [parameter()]
        [string] $type,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "hosts"
    }

    process {
        if ($host_group) {
            Write-Verbose "host_group specified, parsing SDP object reference"
            $PSBoundParameters.host_group = ConvertTo-SDPObjectPrefix -ObjectPath host_groups -ObjectID $host_group -nestedObject
        }

        $PSBoundParameters.Remove('doNotResolve') | Out-Null
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI

        $instances = foreach ($hit in $results) {
            [SDPHost]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
