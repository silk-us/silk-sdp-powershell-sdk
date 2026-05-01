<#
    .SYNOPSIS
    Retrieves network port information from the SDP.

    .DESCRIPTION
    Queries the `system/net_ports` endpoint. Filter by port_type
    ('dataport','mgmtport','ib'), name, or id.

    .EXAMPLE
    Get-SDPSystemNetPorts

    .EXAMPLE
    Get-SDPSystemNetPorts -port_type dataport

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemNetPorts {
    [CmdletBinding()]
    param(
        [parameter()]
        [Alias("PortType")]
        [ValidateSet('dataport','mgmtport','ib')]
        [string] $port_type,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $pipeId,
        [parameter()]
        [string] $pipeName,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/net_ports"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPSystemNetPort'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
