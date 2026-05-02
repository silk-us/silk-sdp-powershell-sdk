<#
    .SYNOPSIS
    Retrieves the SDP partial system parameters block.

    .DESCRIPTION
    Returns the `partial_system_parameters` document — a tunables blob
    used by SDP system administration.

    .PARAMETER doNotResolve
    Skip the post-call ref-resolution pass. Returns raw API records.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemPartialParameters {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "system/partial_system_parameters"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI |
            Add-SDPTypeName -TypeName 'SDPSystemPartialParameters'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
