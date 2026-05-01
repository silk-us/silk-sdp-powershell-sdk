<#
    .SYNOPSIS
    Gather the requested event information.

    .DESCRIPTION
    Queries the SDP audit event log. Filter by event id, level, message,
    user, or a `-after` cutoff. Most events are read-only audit records
    with no resolvable refs, but ref-resolution is wired in for
    consistency with the rest of the SDK.

    .PARAMETER event_id
    Numeric event-type code (e.g. 28 for DELETE_VOLUME).

    .PARAMETER id
    The unique identifier of a specific event record.

    .PARAMETER labels
    Filter by event label.

    .PARAMETER level
    Filter by event severity level.

    .PARAMETER message
    Filter by message text.

    .PARAMETER name
    Filter by event name.

    .PARAMETER after
    Return only events after this DateTime. Converted to a Unix
    timestamp and sent as a `>=` filter.

    .PARAMETER user
    Filter by the user who triggered the event.

    .PARAMETER doNotResolve
    Skip the post-call ref-resolution pass. Returns raw API records.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Get-SDPEvents -EventId 28
    Returns all DELETE_VOLUME events.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPEvents {
    [CmdletBinding()]
    param(
        [parameter()]
        [Alias("EventId")]
        [int] $event_id,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $labels,
        [parameter()]
        [string] $level,
        [parameter()]
        [string] $message,
        [parameter()]
        [string] $name,
        [parameter()]
        [datetime] $after,
        [parameter()]
        [string] $user,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'events'
    }

    process {
        if ($after) {
            $afterTimestamp = Convert-SDPTimeStampTo -timestamp $after -int
            $PSBoundParameters.Remove('after') | Out-Null
            $PSBoundParameters.timestamp = $afterTimestamp
        }

        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI -strictURIgte timestamp

        # Project each raw record into a flat psobject and convert the
        # Unix timestamp to a DateTime for human readability.
        $events = foreach ($hit in $results) {
            $eventRecord = New-Object psobject
            $eventRecord | Add-Member -MemberType NoteProperty -Name event_id -Value $hit.event_id
            $eventRecord | Add-Member -MemberType NoteProperty -Name id -Value $hit.id
            $eventRecord | Add-Member -MemberType NoteProperty -Name labels -Value $hit.labels
            $eventRecord | Add-Member -MemberType NoteProperty -Name level -Value $hit.level
            $eventRecord | Add-Member -MemberType NoteProperty -Name message -Value $hit.message
            $eventRecord | Add-Member -MemberType NoteProperty -Name name -Value $hit.name
            if ($hit.timestamp) {
                $eventRecord | Add-Member -MemberType NoteProperty -Name timestamp -Value (Convert-SDPTimeStampFrom -timestamp $hit.timestamp)
            } else {
                $eventRecord | Add-Member -MemberType NoteProperty -Name timestamp -Value $null
            }
            $eventRecord | Add-Member -MemberType NoteProperty -Name user -Value $hit.user
            $eventRecord
        }

        $events = $events | Add-SDPTypeName -TypeName 'SDPEvent'

        if ($doNotResolve) {
            return $events
        }
        return ($events | Update-SDPRefObjects -k2context $k2context)
    }
}
