<#
    .SYNOPSIS
    Deletes a volume group from the SDP.

    .DESCRIPTION
    Removes an existing volume group from the Silk Data Pod. The volume group must not contain any volumes.

    .PARAMETER id
    The unique identifier of the volume group to remove. Accepts piped input from Get-SDPVolumeGroup.

    .PARAMETER name
    The name of the volume group to remove.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Remove-SDPVolumeGroup -name "VG01"
    Removes the volume group named "VG01".

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01" | Remove-SDPVolumeGroup
    Removes a volume group using piped input.

    .EXAMPLE
    Remove-SDPVolumeGroup -id 15
    Removes the volume group with ID 15.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Remove-SDPVolumeGroup {
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
        # Special Ops

        if ($name) {
            $volgrpname = Get-SDPVolumeGroup -name $name -k2context $k2context
            if (!$volgrpname) {
                return "No volume with name $name exists."
            } elseif (($volgrpname | measure-object).count -gt 1) {
                return "Too many replies with $name"
            } else {
                $id = $volgrpname.id
            }
        }

        ## Make the call

        $endpointURI = $endpoint + '/' + $id

        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
        return $results
    }
}
