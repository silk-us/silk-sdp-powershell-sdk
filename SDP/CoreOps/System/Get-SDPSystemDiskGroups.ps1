function Get-SDPSystemDiskGroups {
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IsExpansionInProgress")]
        [bool] $is_expansion_in_progress,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("RaidLevel")]
        [string] $raid_level,
        [parameter()]
        [Alias("RebuildProgressPercentage")]
        [int] $rebuild_progress_percentage,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "system/disk_groups"

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }
    return $results
}
