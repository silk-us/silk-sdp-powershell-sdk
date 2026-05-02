<#
    .SYNOPSIS
    Retrieves Fibre Channel ports registered to SDP hosts.

    .DESCRIPTION
    Returns FC port (PWWN) entries associated with SDP host objects.

    .PARAMETER hostref
    The host reference to filter by. Sent as `host` on the wire.

    .PARAMETER id
    The unique identifier of the FC port record.

    .PARAMETER pwwn
    Filter by Port World Wide Name.

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

function Get-SDPHostFcPorts {
    [CmdletBinding()]
    param(
        [parameter()]
        [Alias("host")]
        [string] $hostref,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $pwwn,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "host_fc_ports"
    }

    process {
        if ($hostref) {
            $PSBoundParameters.host = $PSBoundParameters.hostref
            $PSBoundParameters.Remove('hostref') | Out-Null
        }

        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI |
            Add-SDPTypeName -TypeName 'SDPHostFcPort'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
