function Get-SDPEventsTargets {
    param(
        [parameter()]
        [string] $data,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $type,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    $endpoint = "events/targets"

    $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    return $results
}
