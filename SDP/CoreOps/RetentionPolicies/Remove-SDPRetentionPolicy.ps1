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
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        # Typed as [object] to dodge module load-order coupling on the
        # SDPRetentionPolicy class. Validated at the top of process.
        [parameter(ValueFromPipeline)]
        [object] $InputObject,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "retention_policies"
    }

    process {
        if ($InputObject -and $InputObject -isnot [SDPRetentionPolicy]) {
            throw "Remove-SDPRetentionPolicy accepts pipeline input only from SDPRetentionPolicy; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $id = $InputObject.id
            if (-not $PSBoundParameters.ContainsKey('k2context')) {
                $k2context = $InputObject.k2context
            }
        }

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPRetentionPolicy id=$id", 'Remove')) {
            Write-Verbose "Removing retention policy with id $id"
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
            return $results
        }
    }
}
