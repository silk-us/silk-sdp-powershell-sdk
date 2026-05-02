<#
    .SYNOPSIS
    Retrieves configured event targets from the SDP.

    .DESCRIPTION
    Returns the list of registered event targets (syslog, SNMP, email,
    etc.) that the SDP forwards audit events to.

    .PARAMETER data
    Filter by target connection data.

    .PARAMETER id
    The unique identifier of the target.

    .PARAMETER name
    Filter by target name.

    .PARAMETER type
    Filter by target type (e.g. syslog, snmp).

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

function Get-SDPEventsTargets {
    [CmdletBinding()]
    param(
        [parameter()]
        [string] $data,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $type,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "events/targets"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI |
            Add-SDPTypeName -TypeName 'SDPEventTarget'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
