<#
    .SYNOPSIS
    Deletes a host from the SDP.

    .DESCRIPTION
    Removes an existing host object from the Silk Data Pod. The host must
    not have any active mappings or identifiers (IQNs, PWWNs, NQNs)
    attached.

    .PARAMETER id
    The unique identifier of the host. Accepts piped input from Get-SDPHost.

    .PARAMETER name
    The name of the host to remove.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Remove-SDPHost -name "WinHost01"

    .EXAMPLE
    Get-SDPHost -name "WinHost01" | Remove-SDPHost

    .EXAMPLE
    Remove-SDPHost -id 45

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPHost {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        # Typed as [object] to dodge module load-order coupling on the
        # SDPHost class. Validated to [SDPHost] at the top of process.
        [parameter(ValueFromPipeline)]
        [object] $InputObject,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter(Position=1)]
        [string] $name,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "hosts"
    }

    process {
        if ($InputObject -and $InputObject -isnot [SDPHost]) {
            throw "Remove-SDPHost accepts pipeline input only from SDPHost; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $id = $InputObject.id
            if (-not $PSBoundParameters.ContainsKey('k2context')) {
                $k2context = $InputObject.k2context
            }
        }

        if ($name) {
            $id = (Get-SDPHost -name $name -k2context $k2context).id
        }

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPHost id=$id", 'Remove')) {
            Write-Verbose "Removing host with id $id"
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
            return $results
        }
    }
}
