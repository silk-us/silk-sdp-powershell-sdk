<#
    .SYNOPSIS
    Creates a new static route on the SDP.

    .DESCRIPTION
    Adds a static route to the Silk Data Pod's management network.

    .PARAMETER destinationSubnetIp
    The destination subnet IP address.

    .PARAMETER destinationSubnetMask
    The destination subnet mask.

    .PARAMETER gatewayIp
    The gateway IP address used to reach the destination subnet.

    .PARAMETER context
    Specifies the K2 context to use for authentication. Defaults to
    'sdpconnection'.

    .EXAMPLE
    New-SDPStaticRoute -destinationSubnetIp 10.10.0.0 -destinationSubnetMask 255.255.0.0 -gatewayIp 192.168.1.1

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPStaticRoute {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [IPAddress] $destinationSubnetIp,
        [parameter(Mandatory)]
        [IPAddress] $destinationSubnetMask,
        [parameter(Mandatory)]
        [IPAddress] $gatewayIp,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = 'static_routes'
    }

    process {
        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "destination_subnet_ip" -Value $destinationSubnetIp.IPAddressToString
        $body | Add-Member -MemberType NoteProperty -Name "destination_subnet_mask" -Value $destinationSubnetMask.IPAddressToString
        $body | Add-Member -MemberType NoteProperty -Name "gateway_ip" -Value $gatewayIp.IPAddressToString

        # Make the call

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -context $context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        return $body
    }
}
