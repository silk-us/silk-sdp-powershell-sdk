<#
    .SYNOPSIS
    Deletes a volume group view from the SDP.

    .DESCRIPTION
    Removes a view (snapshot record with `is_exposable=true`). The view
    must not have any active host mappings — remove those first.

    .PARAMETER id
    The unique identifier of the view to remove. Accepts piped input
    from Get-SDPVolumeGroupView.

    .PARAMETER k2context
    K2 context name. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Remove-SDPVolumeGroupView -id 12

    .EXAMPLE
    Get-SDPVolumeGroupView -name "test-vg:test-view" | Remove-SDPVolumeGroupView

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPVolumeGroupView {
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
        Write-Verbose "Removing view with id $id"
        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
        return $results
    }
}
