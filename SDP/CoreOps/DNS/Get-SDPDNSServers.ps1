<#
    .SYNOPSIS
    Retrieves the configured DNS servers from the SDP.

    .DESCRIPTION
    Pulls the DNS server fields out of the SDP partial system parameters
    endpoint. Returns just the dns_* properties.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPDNSServers

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPDNSServers {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/partial_system_parameters"
    }

    process {

        try {
            $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -k2context $k2context -ErrorAction SilentlyContinue | Select-Object dns_*
        } catch {
            return $Error[0]
        }

        $results = $results | Add-SDPTypeName -TypeName 'SDPDNSServer'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
