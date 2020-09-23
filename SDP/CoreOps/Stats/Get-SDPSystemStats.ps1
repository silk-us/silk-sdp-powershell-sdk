function Get-SDPSystemStats {
    param(
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = 'stats/system'
    }

    process {
        $results = Invoke-SDPRestCall -method GET -endpoint $endpoint
        return $results
    }
}