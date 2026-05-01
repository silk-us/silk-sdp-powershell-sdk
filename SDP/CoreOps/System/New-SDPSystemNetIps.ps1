<#
    .SYNOPSIS
    Configures an IP address on an SDP network port.

    .DESCRIPTION
    Assigns an IP and subnet mask to a specified NetPort and tags it
    with a service type ('iscsi' or 'Replication'). Accepts piped input
    from Get-SDPSystemNetPorts.

    .EXAMPLE
    Get-SDPSystemNetPorts -name c-node02_dataport01 |
        New-SDPSystemNetIps -ipAddress 10.100.5.2 -subnetMask 255.255.255.0 -service iscsi

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPSystemNetIps {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [IPAddress] $ipAddress,
        [Parameter(Mandatory)]
        [IPAddress] $subnetMask,
        [Parameter(Mandatory)]
        [ValidateSet('iscsi','Replication', IgnoreCase = $false)]
        [string] $service,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $interface,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "system/net_ips"
    }

    process {
        $interfacePath = ConvertTo-SDPObjectPrefix -ObjectPath 'system/net_ports' -ObjectID $interface -nestedObject

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "ip_address" -Value $ipAddress.IPAddressToString
        $body | Add-Member -MemberType NoteProperty -Name "network_mask" -Value $subnetMask.IPAddressToString
        $body | Add-Member -MemberType NoteProperty -Name "service" -Value $service
        $body | Add-Member -MemberType NoteProperty -Name "interface" -Value $interfacePath

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue
            Start-Sleep 1
        } catch {
            return $Error[0]
        }

        $results = Get-SDPSystemNetIps -ip_address $ipAddress.IPAddressToString -k2context $k2context

        if ($results) {
            return $results
        } else {
            $message = "Unable to assign IP $ipAddress to network interface. Please check the specified IP."
            return $message | Write-Error
        }
    }
}
