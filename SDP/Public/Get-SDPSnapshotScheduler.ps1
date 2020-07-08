function Get-SDPSnapshotScheduler {
    param(
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    $endpoint = "snapshot_scheduler"

    $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    return $results
}
