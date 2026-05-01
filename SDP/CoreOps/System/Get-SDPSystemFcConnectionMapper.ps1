<#
    .SYNOPSIS
    Retrieves FC connection mapper state from the SDP.

    .DESCRIPTION
    Queries the `system/fc_connection_mapper` endpoint. Filter by host
    FC port, server, server FC port, or id.

    .EXAMPLE
    Get-SDPSystemFcConnectionMapper

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemFcConnectionMapper {
    [CmdletBinding()]
    param(
        [parameter()]
        [Alias("HostFcPort")]
        [string] $host_fc_port,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $server,
        [parameter()]
        [Alias("ServerFcPort")]
        [string] $server_fc_port,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/fc_connection_mapper"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPSystemFcConnection'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
