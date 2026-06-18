function Get-SDPReplicationRpoHistory {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    $endpoint = "replication/rpo_history"

    $PSBoundParameters.Remove('doNotResolve') | Out-Null

    if ($PSBoundParameters.Keys.Contains('Verbose')) {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -Verbose -context $context -strictURI
    } else {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI
    }

    $results = $results | Add-SDPTypeName -TypeName 'SDPReplicationRpoEntry'

    if ($doNotResolve) {
        return $results
    }
    return ($results | Update-SDPRefObjects -context $context)
}
