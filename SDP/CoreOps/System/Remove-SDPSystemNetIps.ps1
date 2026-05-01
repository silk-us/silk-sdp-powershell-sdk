<#
    .SYNOPSIS
    Removes a configured IP address from an SDP network port.

    .DESCRIPTION
    Deletes the net_ips record by id. Accepts piped input from
    Get-SDPSystemNetIps.

    .EXAMPLE
    Get-SDPSystemNetIps | Where-Object {$_.ip_address -eq '10.100.5.2'} | Remove-SDPSystemNetIps

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPSystemNetIps {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "system/net_ips"
    }

    process {
        $endpointURI = "$endpoint/$id"
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
        return $results
    }
}
