<#
    .SYNOPSIS
    Retrieves snapshot scheduler mappings from the SDP.

    .DESCRIPTION
    Returns the mappings between snapshot schedulers and the volume
    groups they apply to.

    .PARAMETER doNotResolve
    Skip the post-call ref-resolution pass. Returns raw API records.

    .PARAMETER context
    Specifies the K2 context to use for authentication. Defaults to
    'sdpconnection'.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSnapshotSchedulerMapping {
    [CmdletBinding()]
    param(
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = "snapshot_scheduler_mapping"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI |
            Add-SDPTypeName -TypeName 'SDPSnapshotSchedulerMapping'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -context $context)
    }
}
