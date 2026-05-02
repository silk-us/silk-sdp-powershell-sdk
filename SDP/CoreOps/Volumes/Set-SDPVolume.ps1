<#
    .SYNOPSIS
    Modifies properties of an existing volume.

    .DESCRIPTION
    Updates configuration settings for an existing volume on the Silk Data
    Pod. Can modify name, size, description, and volume group assignment.

    .PARAMETER id
    The unique identifier of the volume to modify. Accepts piped input from
    Get-SDPVolume.

    .PARAMETER name
    New name for the volume.

    .PARAMETER sizeInGB
    New size for the volume in gigabytes. Volume size can only be increased,
    not decreased.

    .PARAMETER Description
    New description for the volume.

    .PARAMETER VolumeGroupName
    Move the volume to a different volume group by specifying the volume
    group name.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Set-SDPVolume -id 123 -sizeInGB 200
    Expands the volume with ID 123 to 200GB.

    .EXAMPLE
    Get-SDPVolume -name "Vol01" | Set-SDPVolume -name "Vol01-Renamed"
    Renames a volume using piped input.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPVolume {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $sizeInGB,
        [parameter()]
        [string] $Description,
        [parameter()]
        [string] $VolumeGroupName,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "volumes"
    }

    process {

        # Special Ops

        if ($sizeInGB) {
            [string] $size = ($sizeInGB * 1024 * 1024)
            Write-Verbose "$sizeInGB GB converted to $size"
        }

        if ($VolumeGroupName) {
            Write-Verbose "Working with volume group name $VolumeGroupName"
            $volumeGroup = Get-SDPVolumeGroup -name $VolumeGroupName -k2context $k2context
            if (!$volumeGroup) {
                return "No volume group named $VolumeGroupName exists."
            }
            $volumeGroupRef = ConvertTo-SDPObjectPrefix -ObjectPath volume_groups -ObjectID $volumeGroup.id -nestedObject
        }

        # Build the request body

        $body = New-Object psobject
        if ($name) {
            $body | Add-Member -MemberType NoteProperty -Name name -Value $name
        }
        if ($size) {
            $body | Add-Member -MemberType NoteProperty -Name size -Value $size
        }
        if ($volumeGroupRef) {
            $body | Add-Member -MemberType NoteProperty -Name volume_group -Value $volumeGroupRef
        }
        if ($Description) {
            $body | Add-Member -MemberType NoteProperty -Name description -Value $Description
        }

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method PATCH -body $body -k2context $k2context
        return $results
    }
}
