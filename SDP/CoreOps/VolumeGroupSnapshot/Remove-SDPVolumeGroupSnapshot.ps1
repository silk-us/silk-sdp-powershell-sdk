<#
    .SYNOPSIS
    Deletes a snapshot, view, or view-snapshot from the SDP.

    .DESCRIPTION
    The /snapshots endpoint stores all three concepts (regular snapshot,
    view, view-snapshot) under one resource type — a DELETE on the id is
    source-agnostic. This cmdlet handles all of them.

    .PARAMETER id
    The unique identifier of the snapshot to remove. Accepts piped input
    from Get-SDPVolumeGroupSnapshot, Get-SDPVolumeGroupView, etc.

    .PARAMETER k2context
    K2 context name. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Remove-SDPVolumeGroupSnapshot -id 41

    .EXAMPLE
    Get-SDPVolumeGroupSnapshot -name "test-vg:test-snap" | Remove-SDPVolumeGroupSnapshot

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPVolumeGroupSnapshot {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        # Typed as [object] to dodge module load-order coupling on the
        # SDPVolumeGroupSnapshot class. Validated at the top of process.
        [parameter(ValueFromPipeline)]
        [object] $InputObject,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'snapshots'
    }

    process {
        if ($InputObject -and $InputObject -isnot [SDPVolumeGroupSnapshot]) {
            throw "Remove-SDPVolumeGroupSnapshot accepts pipeline input only from SDPVolumeGroupSnapshot; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $id = $InputObject.id
            if (-not $PSBoundParameters.ContainsKey('k2context')) {
                $k2context = $InputObject.k2context
            }
        }
        if (-not $id) {
            throw "Remove-SDPVolumeGroupSnapshot requires an -id (or piped SDPVolumeGroupSnapshot)."
        }

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPVolumeGroupSnapshot id=$id", 'Remove')) {
            Write-Verbose "Removing snapshot with id $id"
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
            return $results
        }
    }
}
