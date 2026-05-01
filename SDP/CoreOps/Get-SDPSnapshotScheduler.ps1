function Get-SDPSnapshotScheduler {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    $endpoint = "snapshot_scheduler"

    $PSBoundParameters.Remove('doNotResolve') | Out-Null
    $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
        Add-SDPTypeName -TypeName 'SDPSnapshotScheduler'

    if ($doNotResolve) {
        return $results
    }
    return ($results | Update-SDPRefObjects -k2context $k2context)
}
