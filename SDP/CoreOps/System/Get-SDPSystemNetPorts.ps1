function Get-SDPSystemNetPorts {
    param(
        [parameter()]
        [Alias("AutoNegotiation")]
        [string] $auto_negotiation,
        [parameter()]
        [Alias("ContainedIn")]
        [string] $contained_in,
        [parameter()]
        [Alias("FlowControl")]
        [string] $flow_control,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IsFru")]
        [bool] $is_fru,
        [parameter()]
        [Alias("LinkState")]
        [string] $link_state,
        [parameter()]
        [Alias("MacAddr")]
        [string] $mac_addr,
        [parameter()]
        [string] $mtu,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $pipeId,
        [parameter()]
        [string] $pipeName,
        [parameter()]
        [Alias("PortType")]
        [string] $port_type,
        [parameter()]
        [string] $server,
        [parameter()]
        [Alias("SpeedState")]
        [string] $speed_state,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/net_ports"
    }
    
    process {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        return $results
    }
}