function Get-SDPSystemCapacity {
    param(
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin{
        $endpoint = "system/capacity"
    }
    
    Process {
        if ($PSBoundParameters.Keys.Contains('Verbose')) {
            $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
        } else {
            $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        }
        return $results
    }

}
