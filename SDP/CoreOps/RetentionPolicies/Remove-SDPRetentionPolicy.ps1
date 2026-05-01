<#
    .SYNOPSIS
    Deletes a retention policy from the SDP.

    .DESCRIPTION
    Removes a snapshot retention policy from the Silk Data Pod. The
    policy must not be in use by any volume groups.

    .PARAMETER id
    The unique identifier of the retention policy to remove. Accepts
    piped input from Get-SDPRetentionPolicy.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Remove-SDPRetentionPolicy -id 5
    Removes the retention policy with ID 5.

    .EXAMPLE
    Get-SDPRetentionPolicy -name "Policy01" | Remove-SDPRetentionPolicy
    Removes a retention policy using piped input.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPRetentionPolicy {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "retention_policies"
    }

    process {
        Write-Verbose "Removing retention policy with id $id"
        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
        return $results
    }
}
