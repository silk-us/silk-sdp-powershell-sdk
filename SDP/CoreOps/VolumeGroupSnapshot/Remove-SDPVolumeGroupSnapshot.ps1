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
    [CmdletBinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'snapshots'
    }

    process {
        Write-Verbose "Removing snapshot with id $id"
        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
        return $results
    }
}
