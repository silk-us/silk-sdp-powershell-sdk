<#
    .SYNOPSIS
    Retrieves total system capacity information from the SDP.

    .DESCRIPTION
    Queries the `system/capacity` endpoint.

    .EXAMPLE
    Get-SDPSystemCapacity

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemCapacity {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "system/capacity"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPSystemCapacity'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
