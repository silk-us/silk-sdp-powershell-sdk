function Get-SDPReplicationPeerWanPorts {
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("RemoteWanPortIpAddress")]
        [string] $remote_wan_port_ip_address,
        [parameter()]
        [Alias("RemoteWanPortName")]
        [string] $remote_wan_port_name,
        [parameter()]
        [Alias("ReplicationPeerK2array")]
        [string] $replication_peer_k2array,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "replication/peer_wan_ports"

    $PSBoundParameters.Remove('doNotResolve') | Out-Null

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context -strictURI
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI
    }

    $results = $results | Add-SDPTypeName -TypeName 'SDPReplicationPeerWanPort'

    if ($doNotResolve) {
        return $results
    }
    return ($results | Update-SDPRefObjects -k2context $k2context)
}
