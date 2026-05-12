<#
    .SYNOPSIS
    Retrieves FC port state from the SDP.

    .DESCRIPTION
    Queries the `system/fc_ports` endpoint. Filter by name, id, pwwn,
    server, speed state, or status.

    .EXAMPLE
    Get-SDPSystemFcPorts

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemFcPorts {
    [CmdletBinding()]
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $pwwn,
        [parameter()]
        [string] $server,
        [parameter()]
        [Alias("SpeedState")]
        [string] $speed_state,
        [parameter()]
        [string] $status,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $context = "sdpconnection"
    )

    begin {
        $endpoint = "system/fc_ports"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI |
            Add-SDPTypeName -TypeName 'SDPSystemFcPort'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -context $context)
    }
}
