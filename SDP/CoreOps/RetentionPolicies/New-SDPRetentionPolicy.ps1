<#
    .SYNOPSIS
    Creates a new retention policy on the SDP.

    .DESCRIPTION
    Creates a new snapshot retention policy on the Silk Data Pod.
    Retention policies define how long snapshots are kept and the
    maximum number that can exist before automatic deletion.

    .PARAMETER name
    The name for the new retention policy.

    .PARAMETER snapshotCount
    Maximum number of snapshots to retain.

    .PARAMETER weeks
    Number of weeks to retain snapshots.

    .PARAMETER days
    Number of days to retain snapshots.

    .PARAMETER hours
    Number of hours to retain snapshots.

    .PARAMETER context
    Specifies the K2 context to use for authentication. Defaults to
    'sdpconnection'.

    .EXAMPLE
    New-SDPRetentionPolicy -name "Daily7" -snapshotCount 7 -weeks 0 -days 7 -hours 0
    Creates a retention policy keeping 7 daily snapshots.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPRetentionPolicy {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [int] $snapshotCount,
        [parameter(Mandatory)]
        [int] $weeks,
        [parameter(Mandatory)]
        [int] $days,
        [parameter(Mandatory)]
        [int] $hours,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = "retention_policies"
    }

    process {

        # Build the request body — snake_case API fields built directly
        # into $body. The API expects string values for the integer fields.

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name name          -Value $name
        $body | Add-Member -MemberType NoteProperty -Name num_snapshots -Value $snapshotCount.ToString()
        $body | Add-Member -MemberType NoteProperty -Name weeks         -Value $weeks.ToString()
        $body | Add-Member -MemberType NoteProperty -Name days          -Value $days.ToString()
        $body | Add-Member -MemberType NoteProperty -Name hours         -Value $hours.ToString()

        # POST returns nothing on success — submit and then poll the GET
        # until the new policy appears.

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -context $context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $name -Get {
            Get-SDPRetentionPolicy -name $name -context $context
        }

        return $results
    }
}
