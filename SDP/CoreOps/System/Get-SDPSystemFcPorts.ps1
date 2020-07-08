function Get-SDPSystemFcPorts {
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $pwwn,
        [parameter()]
        [string] $server,
        [parameter()]
        [Alias("SpeedState")]
        [string] $speed_state,
        [parameter()]
        [string] $status,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "system/fc_ports"

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }
    return $results
}
