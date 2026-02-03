<#
    .SYNOPSIS
    Retrieves retention policies from the SDP.

    .DESCRIPTION
    Queries for snapshot retention policies on the Silk Data Pod. Retention policies define how long snapshots are kept before automatic deletion.

    .PARAMETER id
    The unique identifier of the retention policy.

    .PARAMETER name
    The name of the retention policy to retrieve.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPRetentionPolicy
    Retrieves all retention policies from the SDP.

    .EXAMPLE
    Get-SDPRetentionPolicy -name "Policy01"
    Retrieves the retention policy named "Policy01".

    .EXAMPLE
    Get-SDPRetentionPolicy -id 5
    Retrieves the retention policy with ID 5.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Get-SDPRetentionPolicy {
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    begin {
        $endpoint = "retention_policies"
    }

    process {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        return $results
    }
}
