<#
    .SYNOPSIS
    Deletes a volume group from the SDP.

    .DESCRIPTION
    Removes an existing volume group from the Silk Data Pod. The volume
    group must not contain any volumes.

    .PARAMETER id
    The unique identifier of the volume group to remove. Accepts piped
    input from Get-SDPVolumeGroup.

    .PARAMETER name
    The name of the volume group to remove.

    .PARAMETER context
    Specifies the K2 context to use for authentication. Defaults to
    'sdpconnection'.

    .EXAMPLE
    Remove-SDPVolumeGroup -name "VG01"

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01" | Remove-SDPVolumeGroup

    .EXAMPLE
    Remove-SDPVolumeGroup -id 15

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPVolumeGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        # Typed as [object] to dodge module load-order coupling on the
        # SDPVolumeGroup class. Validated to [SDPVolumeGroup] at the top of process.
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
        $endpoint = "volume_groups"
    }

    process {

        if ($InputObject -and $InputObject -isnot [SDPVolumeGroup]) {
            throw "Remove-SDPVolumeGroup accepts pipeline input only from SDPVolumeGroup; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $id = $InputObject.id
            if (-not $PSBoundParameters.ContainsKey('context')) {
                $context = $InputObject.context
            }
        }

        # Special Ops — resolve name to id when no id was passed.

        if ($name) {
            $volumeGroup = Get-SDPVolumeGroup -name $name -context $context
            if (!$volumeGroup) {
                return "No volume group with name $name exists."
            } elseif (($volumeGroup | Measure-Object).Count -gt 1) {
                return "Too many replies with $name"
            } else {
                $id = $volumeGroup.id
            }
        }

        # Call

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPVolumeGroup id=$id", 'Remove')) {
            Write-Verbose "Removing volume group with id $id"
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -context $context
            return $results
        }
    }
}
