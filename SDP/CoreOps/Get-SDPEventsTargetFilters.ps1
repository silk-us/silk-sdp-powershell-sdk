function Get-SDPEventsTargetFilters {
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $label,
        [parameter()]
        [string] $level,
        [parameter()]
        [Alias("TargetId")]
        [int] $target_id,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    $endpoint = "events/target_filters"

    $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    return $results
}
