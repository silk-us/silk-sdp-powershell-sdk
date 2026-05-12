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
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = "system/net_ips"
    }

    process {
        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPSystemNetIp id=$id", 'Remove')) {
            $endpointURI = "$endpoint/$id"
            $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -context $context
            return $results
        }
    }
}
