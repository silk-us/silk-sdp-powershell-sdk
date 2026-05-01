<#
    .SYNOPSIS
    Retrieves expander hardware state from the SDP.

    .DESCRIPTION
    Queries the `system/expanders` endpoint. Filter by name, id,
    connectivity state, FRU/phased-out flags, NDU state, etc.

    .EXAMPLE
    Get-SDPSystemExpanders

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemExpanders {
    [CmdletBinding()]
    param(
        [parameter()]
        [Alias("ConnectivityState")]
        [string] $connectivity_state,
        [parameter()]
        [Alias("ContainedIn")]
        [string] $contained_in,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IsExpansionInProgress")]
        [bool] $is_expansion_in_progress,
        [parameter()]
        [Alias("IsFru")]
        [bool] $is_fru,
        [parameter()]
        [Alias("IsPhasedOut")]
        [bool] $is_phased_out,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("NduState")]
        [string] $ndu_state,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/expanders"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPSystemExpander'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
