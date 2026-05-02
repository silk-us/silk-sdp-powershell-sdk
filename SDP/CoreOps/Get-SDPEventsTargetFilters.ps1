<#
    .SYNOPSIS
    Retrieves event target filter configuration from the SDP.

    .DESCRIPTION
    Queries the per-target event filters that control which events get
    forwarded to a configured event target (syslog, SNMP, etc.).

    .PARAMETER id
    The unique identifier of the filter.

    .PARAMETER label
    Filter by event label.

    .PARAMETER level
    Filter by event severity level.

    .PARAMETER target_id
    The id of the parent event target.

    .PARAMETER doNotResolve
    Skip the post-call ref-resolution pass. Returns raw API records.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPEventsTargetFilters {
    [CmdletBinding()]
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $label,
        [parameter()]
        [string] $level,
        [parameter()]
        [Alias("TargetId")]
        [int] $target_id,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "events/target_filters"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI |
            Add-SDPTypeName -TypeName 'SDPEventTargetFilter'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
