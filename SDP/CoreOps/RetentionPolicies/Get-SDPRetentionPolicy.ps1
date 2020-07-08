function Get-SDPRetentionPolicy {
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    begin {
        $endpoint = "retention_policies"
    }

    process {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        return $results
    }
}
