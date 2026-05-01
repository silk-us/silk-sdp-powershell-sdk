<#
    .SYNOPSIS
    Configures the DNS servers on the SDP.

    .DESCRIPTION
    PATCHes the SDP partial system parameters endpoint with up to three
    DNS server addresses.

    .PARAMETER DNSServer1
    Primary DNS server IP address.

    .PARAMETER DNSServer2
    Secondary DNS server IP address.

    .PARAMETER DNSServer3
    Tertiary DNS server IP address.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Set-SDPDNSServers -DNSServer1 8.8.8.8 -DNSServer2 8.8.4.4

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPDNSServers {
    [CmdletBinding()]
    param(
        [parameter()]
        [ipaddress] $DNSServer1,
        [parameter()]
        [ipaddress] $DNSServer2,
        [parameter()]
        [ipaddress] $DNSServer3,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/partial_system_parameters"
    }

    process {

        # Build the request body

        $body = New-Object psobject
        if ($DNSServer1) {
            $body | Add-Member -MemberType NoteProperty -Name "dns_server1" -Value $DNSServer1.IPAddressToString
        }
        if ($DNSServer2) {
            $body | Add-Member -MemberType NoteProperty -Name "dns_server1" -Value $DNSServer2.IPAddressToString
        }
        if ($DNSServer3) {
            $body | Add-Member -MemberType NoteProperty -Name "dns_server1" -Value $DNSServer3.IPAddressToString
        }

        # Call

        try {
            $results = Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $body -k2context $k2context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        return $results
    }
}
