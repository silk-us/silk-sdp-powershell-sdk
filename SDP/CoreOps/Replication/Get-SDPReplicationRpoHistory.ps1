function Get-SDPReplicationRpoHistory {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    $endpoint = "replication/rpo_history"

    $PSBoundParameters.Remove('doNotResolve') | Out-Null

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -k2context $k2context
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
    }

    $results = $results | Add-SDPTypeName -TypeName 'SDPReplicationRpoEntry'

    if ($doNotResolve) {
        return $results
    }
    return ($results | Update-SDPRefObjects -k2context $k2context)
}
