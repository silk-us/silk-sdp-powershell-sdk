<#
    SDPHostMapping — typed wrapper for a Silk SDP host-to-volume mapping.

    A mapping has no `name` property on the API; it is identified by id.
    `host_name` and `volume_name` are attached at runtime by
    Update-SDPRefObjects (from the host and volume nested refs).
#>

class SDPHostMapping {

    # --- Properties shown in the default table view ---
    [string]   $id
    [int]      $lun

    # --- Refs preserved for Update-SDPRefObjects to walk. ---
    [psobject] $host
    [psobject] $volume

    # Hidden context
    hidden [string] $k2context

    SDPHostMapping() {}

    SDPHostMapping([psobject] $apiHit, [string] $k2context) {
        $this.id        = $apiHit.id
        $this.lun       = $apiHit.lun
        $this.k2context = $k2context

        if ($apiHit.host)   { $this.host   = $apiHit.host }
        if ($apiHit.volume) { $this.volume = $apiHit.volume }
    }

    # ---- Operational methods --------------------------------------------

    [SDPHostMapping] Refresh() {
        return [SDPHostMapping]::new(
            (Get-SDPHostMapping -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [void] Delete() {
        Remove-SDPHostMapping -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return "mapping/$($this.id) lun=$($this.lun)"
    }
}

Update-TypeData -TypeName 'SDPHostMapping' `
                -DefaultDisplayPropertySet 'id','host_name','volume_name','lun' `
                -Force


<#
    .SYNOPSIS
    Use this function to gather information about existing Host mappings.

    .EXAMPLE
    Get-SDPHostMapping -hostName "Host01"

    .EXAMPLE
    Get-SDPHost -name "Host01" | Get-SDPHostMapping

    .EXAMPLE
    Get-SDPHostMapping -hostName "Host01" -asSnapshot

    .DESCRIPTION
    Query for any host mapping on the SDP. This function accepts piped input from Get-SDPHost.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPHostMapping {
    [CmdletBinding()]
    [OutputType([SDPHostMapping])]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
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
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "mappings"
    }

    process {
        # parameter cleanup — strip internal-only switches before passing
        # PSBoundParameters into the URI builder.
        if ($asSnapshot) {
            Write-Verbose 'removing asSnapshot from parameter list.'
            $PSBoundParameters.remove('asSnapshot') | Out-Null
        }
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        # special ops

        if ($volumeName) {
            $volumeObj = Get-SDPVolume -name $volumeName -k2context $k2context -doNotResolve
            $volumePath = ConvertTo-SDPObjectPrefix -ObjectPath "volumes" -ObjectID $volumeObj.id -nestedObject
            $PSBoundParameters.volume = $volumePath
            $PSBoundParameters.remove('volumeName') | Out-Null
        }

        if ($hostName) {
            $hostObj = Get-SDPHost -name $hostName -k2context $k2context -doNotResolve
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject
            $PSBoundParameters.host = $hostPath
            $PSBoundParameters.remove('hostName') | Out-Null
        }

        # make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        if ($asSnapshot) {
            $results = $results | Where-Object {$_.volume -match '/snapshots/'}
        }

        $results = $results | Where-Object {$_.host.ref -notmatch '/host_groups/'}

        $instances = foreach ($hit in $results) {
            [SDPHostMapping]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
