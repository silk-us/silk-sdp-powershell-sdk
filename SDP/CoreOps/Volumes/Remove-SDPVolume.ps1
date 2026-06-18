<#
    .SYNOPSIS
    Deletes a volume from the SDP.

    .DESCRIPTION
    Removes an existing volume from the Silk Data Pod. The volume must not
    be mapped to any hosts.

    .PARAMETER id
    The unique identifier of the volume to remove. Accepts piped input from
    Get-SDPVolume.

    .PARAMETER name
    The name of the volume to remove.

    .PARAMETER context
    Specifies the K2 context to use for authentication. Defaults to
    'sdpconnection'.

    .EXAMPLE
    Remove-SDPVolume -name "Vol01"
    Removes the volume named "Vol01".

    .EXAMPLE
    Get-SDPVolume -name "Vol01" | Remove-SDPVolume
    Removes a volume using piped input.

    .EXAMPLE
    Remove-SDPVolume -id 123
    Removes the volume with ID 123.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPVolume {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        # Typed as [object] to dodge module load-order coupling on the
        # SDPVolume class. Validated to [SDPVolume] at the top of process.
        [parameter(ValueFromPipeline)]
        [object] $InputObject,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = "volumes"
    }

    process {

        if ($InputObject -and $InputObject -isnot [SDPVolume]) {
            throw "Remove-SDPVolume accepts pipeline input only from SDPVolume; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $id = $InputObject.id
            if (-not $PSBoundParameters.ContainsKey('context')) {
                $context = $InputObject.context
            }
        }

        # Special Ops — resolve name to id when no id was passed.

        if ($name) {
            $volume = Get-SDPVolume -name $name -context $context
            if (!$volume) {
                return "No volume with name $name exists."
            } elseif (($volume | Measure-Object).Count -gt 1) {
                return "Too many replies with $name"
            } else {
                $id = $volume.id
            }
        }

        # Call

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPVolume id=$id", 'Remove')) {
            Write-Verbose "Removing volume with id $id"
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -context $context

            return $results
        }
    }
}
