<#
    .SYNOPSIS
    Retrieves configured static routes from the SDP.

    .DESCRIPTION
    Returns the list of static routes configured on the Silk Data Pod's
    management network.

    .PARAMETER destination_subnet_ip
    Filter by destination subnet IP.

    .PARAMETER destination_subnet_mask
    Filter by destination subnet mask.

    .PARAMETER gateway_ip
    Filter by gateway IP.

    .PARAMETER id
    The unique identifier of the static route.

    .PARAMETER knode
    Filter by k-node.

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

function Get-SDPStaticRoute {
    [CmdletBinding()]
    param(
        [parameter()]
        [Alias("DestinationSubnetIp")]
        [string] $destination_subnet_ip,
        [parameter()]
        [Alias("DestinationSubnetMask")]
        [string] $destination_subnet_mask,
        [parameter()]
        [Alias("GatewayIp")]
        [string] $gateway_ip,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $knode,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "static_routes"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPStaticRoute'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
