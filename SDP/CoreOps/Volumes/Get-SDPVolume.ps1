<#
    .SYNOPSIS
    Retrieves volume information from the SDP.

    .DESCRIPTION
    Queries for existing volumes on the Silk Data Pod. Can filter by name, ID, volume group, or other properties.

    .PARAMETER description
    Filter volumes by description text.

    .PARAMETER id
    The unique identifier of the volume.

    .PARAMETER name
    The name of the volume to retrieve.

    .PARAMETER vmware_support
    Filter volumes by VMware support flag.

    .PARAMETER volume_group
    Filter volumes by volume group name or ID. Accepts piped input from Get-SDPVolumeGroup.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolume
    Retrieves all volumes from the SDP.

    .EXAMPLE
    Get-SDPVolume -name "Vol01"
    Retrieves the volume named "Vol01".

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01" | Get-SDPVolume
    Retrieves all volumes in the volume group "VG01".

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Get-SDPVolume {
    param(
        [parameter()]
        [string] $description,
        [parameter()]
        [int] $id,
        [parameter(Position=1)]
        [string] $name,
        [parameter()]
        [Alias("VmwareSupport")]
        [bool] $vmware_support,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [Alias("VolumeGroup")]
        [string] $volume_group,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "volumes"
    }

    process {

        # Special Ops

        if ($volume_group) {
            Write-Verbose "volume_group specified, parsing KDP Object"
            $PSBoundParameters.volume_group = ConvertTo-SDPObjectPrefix -ObjectPath volume_groups -ObjectID $volume_group -nestedObject
        }

        # Query 

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        return $results
    }
}
