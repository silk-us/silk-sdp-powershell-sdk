function Get-SDPSystemBatteries {
    param(
        [parameter()]
        [Alias("ChargeLevelState")]
        [string] $charge_level_state,
        [parameter()]
        [Alias("ConnectivityState")]
        [string] $connectivity_state,
        [parameter()]
        [Alias("ContainedIn")]
        [string] $contained_in,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IsExpansionInProgress")]
        [bool] $is_expansion_in_progress,
        [parameter()]
        [Alias("IsFru")]
        [bool] $is_fru,
        [parameter()]
        [Alias("IsPhasedOut")]
        [bool] $is_phased_out,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("NduState")]
        [string] $ndu_state,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    $endpoint = "system/batteries"

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }
    return $results
}
