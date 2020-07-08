function New-SDPStaticRoute {
    param(
        [parameter(Mandatory)]
        [IPAddress] $destinationSubnetIp,
        [parameter(Mandatory)]
        [IPAddress] $destinationSubnetMask,
        [parameter(Mandatory)]
        [IPAddress] $gatewayIp,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = 'static_routes'
    }

    process{
        ## Special Ops

        $o = New-Object psobject

        $o | Add-Member -MemberType NoteProperty -Name "destination_subnet_ip" -Value $destinationSubnetIp.IPAddressToString
        $o | Add-Member -MemberType NoteProperty -Name "destination_subnet_mask" -Value $destinationSubnetMask.IPAddressToString
        $o | Add-Member -MemberType NoteProperty -Name "gateway_ip" -Value $gatewayIp.IPAddressToString

        # Make the call 

        $body = $o
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }
        return $body
    }
}

