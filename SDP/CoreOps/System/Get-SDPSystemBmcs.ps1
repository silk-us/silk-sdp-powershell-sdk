<#
    .SYNOPSIS
    Retrieves BMC hardware state from the SDP.

    .DESCRIPTION
    Queries the `system/bmcs` endpoint. Filter by name, id, FRU/phased-out
    flags, NDU state, etc.

    .EXAMPLE
    Get-SDPSystemBmcs

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemBmcs {
    [CmdletBinding()]
    param(
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
        $endpoint = "system/bmcs"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI |
            Add-SDPTypeName -TypeName 'SDPSystemBmc'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
