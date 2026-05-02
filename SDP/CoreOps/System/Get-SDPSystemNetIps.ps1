<#
    .SYNOPSIS
    Retrieves network IP information from the SDP.

    .DESCRIPTION
    Queries the `system/net_ips` endpoint. Optionally filters down to a
    specific net_port by piping in a Get-SDPSystemNetPorts result.

    .EXAMPLE
    Get-SDPSystemNetIps

    .EXAMPLE
    Get-SDPSystemNetPorts | Where-Object {$_.name -match "dataport01"} | Get-SDPSystemNetIps

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemNetIps {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string] $portID,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/net_ips"
    }

    process {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -k2context $k2context -strictURI

        if ($portID) {
            $portRef = ConvertTo-SDPObjectPrefix -ObjectID $portID -ObjectPath 'system/net_ports'
            $results = $results | Where-Object { $_.net_port.ref -contains $portRef }
        }

        $results = $results | Add-SDPTypeName -TypeName 'SDPSystemNetIp'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
