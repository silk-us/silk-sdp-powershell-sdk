<#
    .SYNOPSIS
    Remove an existing host mapping.

    .EXAMPLE
    Remove-SDPHostMapping -id 432

    .EXAMPLE
    Get-SDPHostMapping -hostName LinuxHost03 | Remove-SDPHostMapping

    .DESCRIPTION
    Use this function to remove an existing host mapping using these examples. Accepts piped imput from Get-SDPHostMapping

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPHostMapping {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        # Typed as [object] to dodge module load-order coupling on the
        # SDPHostMapping class. Validated to [SDPHostMapping] at the top of process.
        [parameter(ValueFromPipeline)]
        [object] $InputObject,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = 'mappings'
    }

    process {

        if ($InputObject -and $InputObject -isnot [SDPHostMapping]) {
            throw "Remove-SDPHostMapping accepts pipeline input only from SDPHostMapping; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $id = $InputObject.id
            if (-not $PSBoundParameters.ContainsKey('context')) {
                $context = $InputObject.context
            }
        }

        # Call

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPHostMapping id=$id", 'Remove')) {
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -context $context
            return $results
        }
    }
}
