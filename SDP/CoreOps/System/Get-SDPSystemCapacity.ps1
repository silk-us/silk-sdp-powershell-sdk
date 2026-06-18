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
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = "system/capacity"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI |
            Add-SDPTypeName -TypeName 'SDPSystemCapacity'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -context $context)
    }
}
