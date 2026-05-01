<#
    .SYNOPSIS
    Retrieves the system encryption configuration from the SDP.

    .DESCRIPTION
    Queries the `system/encryption` endpoint.

    .EXAMPLE
    Get-SDPSystemEncryption

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemEncryption {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "system/encryption"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPSystemEncryption'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
