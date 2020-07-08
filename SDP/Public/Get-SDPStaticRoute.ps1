function Get-SDPStaticRoute {
    param(
        [parameter()]
        [Alias("DestinationSubnetIp")]
        [string] $destination_subnet_ip,
        [parameter()]
        [Alias("DestinationSubnetMask")]
        [string] $destination_subnet_mask,
        [parameter()]
        [Alias("GatewayIp")]
        [string] $gateway_ip,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $knode,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "static_routes"

    $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    return $results
}
