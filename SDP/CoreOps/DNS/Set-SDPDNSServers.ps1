function Set-SDPDNSServers {
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
    <#
        .SYNOPSIS

        .EXAMPLE 

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = "system/partial_system_parameters"
    }

    process {
        $o = New-Object psobject
        if ($DNSServer1) {
            $o | Add-Member -MemberType NoteProperty -Name "dns_server1" -Value $DNSServer1.IPAddressToString
        }
        if ($DNSServer2) {
            $o | Add-Member -MemberType NoteProperty -Name "dns_server1" -Value $DNSServer2.IPAddressToString
        }
        if ($DNSServer3) {
            $o | Add-Member -MemberType NoteProperty -Name "dns_server1" -Value $DNSServer3.IPAddressToString
        }

        # end special ops

        $body = $o
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $body -k2context $k2context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }
        
        return $results
    }

}