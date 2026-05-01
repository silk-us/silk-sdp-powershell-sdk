<#
    .SYNOPSIS
    Modifies properties of an existing retention policy.

    .DESCRIPTION
    Updates configuration settings for an existing snapshot retention
    policy on the Silk Data Pod. Only fields the caller passes are sent
    in the PATCH body.

    .PARAMETER id
    The unique identifier of the retention policy to modify. Accepts
    piped input from Get-SDPRetentionPolicy.

    .PARAMETER name
    New name for the retention policy.

    .PARAMETER snapshotCount
    New maximum number of snapshots to retain.

    .PARAMETER weeks
    New number of weeks to retain snapshots.

    .PARAMETER days
    New number of days to retain snapshots.

    .PARAMETER hours
    New number of hours to retain snapshots.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Set-SDPRetentionPolicy -id 5 -snapshotCount 14
    Increases the snapshot count for the retention policy with ID 5.

    .EXAMPLE
    Get-SDPRetentionPolicy -name "Policy01" | Set-SDPRetentionPolicy -name "Policy01-Renamed"
    Renames a retention policy using piped input.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPRetentionPolicy {
    [CmdletBinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $snapshotCount,
        [parameter()]
        [int] $weeks,
        [parameter()]
        [int] $days,
        [parameter()]
        [int] $hours,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "retention_policies"
    }

    process {

        # Build the request body — only include fields the caller passed,
        # so PATCH doesn't clobber unrelated values. ContainsKey is used
        # because 0 is a meaningful retention value.

        $body = New-Object psobject
        if ($name) {
            $body | Add-Member -MemberType NoteProperty -Name name -Value $name
        }
        if ($PSBoundParameters.ContainsKey('snapshotCount')) {
            $body | Add-Member -MemberType NoteProperty -Name num_snapshots -Value $snapshotCount.ToString()
        }
        if ($PSBoundParameters.ContainsKey('weeks')) {
            $body | Add-Member -MemberType NoteProperty -Name weeks -Value $weeks.ToString()
        }
        if ($PSBoundParameters.ContainsKey('days')) {
            $body | Add-Member -MemberType NoteProperty -Name days -Value $days.ToString()
        }
        if ($PSBoundParameters.ContainsKey('hours')) {
            $body | Add-Member -MemberType NoteProperty -Name hours -Value $hours.ToString()
        }

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method PATCH -body $body -k2context $k2context
        return $results
    }
}
