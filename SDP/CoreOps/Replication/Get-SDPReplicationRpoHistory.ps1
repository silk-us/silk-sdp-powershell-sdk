function Get-SDPReplicationRpoHistory {
    param(
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    $endpoint = "replication/rpo_history"

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }
    return $results
}
