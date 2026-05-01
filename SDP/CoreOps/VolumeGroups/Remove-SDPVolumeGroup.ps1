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

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

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
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "volume_groups"
    }

    process {

        # Special Ops — resolve name to id when no id was passed.

        if ($name) {
            $volumeGroup = Get-SDPVolumeGroup -name $name -k2context $k2context
            if (!$volumeGroup) {
                return "No volume group with name $name exists."
            } elseif (($volumeGroup | Measure-Object).Count -gt 1) {
                return "Too many replies with $name"
            } else {
                $id = $volumeGroup.id
            }
        }

        # Call

        Write-Verbose "Removing volume group with id $id"
        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
        return $results
    }
}
