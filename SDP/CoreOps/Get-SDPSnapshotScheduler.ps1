function Get-SDPSnapshotScheduler {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    $endpoint = "snapshot_scheduler"

    $PSBoundParameters.Remove('doNotResolve') | Out-Null
    $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI |
        Add-SDPTypeName -TypeName 'SDPSnapshotScheduler'

    if ($doNotResolve) {
        return $results
    }
    return ($results | Update-SDPRefObjects -context $context)
}
