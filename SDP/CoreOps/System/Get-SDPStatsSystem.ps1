<#
    .SYNOPSIS
    Retrieves raw system stats from the SDP.

    .DESCRIPTION
    Thin wrapper over the `stats/system` endpoint. Returns the raw API
    payload. For a richer typed view use Get-SDPSystemStats.

    .PARAMETER doNotResolve
    Skip ref resolution. Stats records typically have no refs, so this is
    here for SDK consistency.

    .PARAMETER context
    K2 context to use for authentication. Defaults to 'sdpconnection'.

    .EXAMPLE
    Get-SDPStatsSystem

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPStatsSystem {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = "stats/system"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI |
            Add-SDPTypeName -TypeName 'SDPStatsSystem'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -context $context)
    }
}
