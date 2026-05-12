<#
    .SYNOPSIS
    Retrieves the overall system state from the SDP.

    .DESCRIPTION
    Queries the `system/state` endpoint.

    .EXAMPLE
    Get-SDPSystemState

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemState {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = "system/state"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI |
            Add-SDPTypeName -TypeName 'SDPSystemState'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -context $context)
    }
}
