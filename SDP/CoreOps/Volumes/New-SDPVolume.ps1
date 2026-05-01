<#
    .SYNOPSIS
    Creates a new volume on the SDP.

    .DESCRIPTION
    Creates a new block storage volume within a specified volume group on
    the Silk Data Pod.

    .PARAMETER name
    The name for the new volume.

    .PARAMETER sizeInGB
    The size of the volume in gigabytes.

    .PARAMETER VolumeGroupName
    The name of the volume group where the volume will be created.

    .PARAMETER volumeGroupId
    The ID of the volume group where the volume will be created. Accepts
    piped input from Get-SDPVolumeGroup.

    .PARAMETER VMWare
    Enables VMware support for the volume (VMFS optimizations).

    .PARAMETER Description
    Optional description for the volume.

    .PARAMETER ReadOnly
    Creates the volume as read-only.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    New-SDPVolume -name "Vol01" -sizeInGB 100 -VolumeGroupName "VG01"
    Creates a 100GB volume named "Vol01" in volume group "VG01".

    .EXAMPLE
    New-SDPVolume -name "VMWareVol" -sizeInGB 500 -VolumeGroupName "VG01" -VMWare
    Creates a 500GB VMware-optimized volume.

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01" | New-SDPVolume -name "Vol02" -sizeInGB 200
    Creates a volume using piped volume group input.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPVolume {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [int] $sizeInGB,
        [parameter()]
        [string] $VolumeGroupName,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $volumeGroupId,
        [parameter()]
        [switch] $VMWare,
        [parameter()]
        [string] $Description,
        [parameter()]
        [switch] $ReadOnly,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "volumes"
    }

    process {

        # Special Ops — resolve the target volume group (by id or name)

        if ($volumeGroupId) {
            Write-Verbose "Working with volume group id $volumeGroupId"
            $volumeGroup = Get-SDPVolumeGroup -id $volumeGroupId -k2context $k2context
            if (!$volumeGroup) {
                return "No volume group with ID $volumeGroupId exists."
            }
        } elseif ($VolumeGroupName) {
            Write-Verbose "Working with volume group name $VolumeGroupName"
            $volumeGroup = Get-SDPVolumeGroup -name $VolumeGroupName -k2context $k2context
            if (!$volumeGroup) {
                return "No volume group named $VolumeGroupName exists."
            }
        }

        try {
            Write-Verbose "Volume group ID = $($volumeGroup.id)"
            $volumeGroupRef = ConvertTo-SDPObjectPrefix -ObjectPath volume_groups -ObjectID $volumeGroup.id -nestedObject
        } catch {
            return "No volume_group discovered"
        }

        # Build the request body

        [string] $size = ($sizeInGB * 1024 * 1024)
        Write-Verbose "$sizeInGB GB converted to $size"

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        $body | Add-Member -MemberType NoteProperty -Name "size" -Value $size
        $body | Add-Member -MemberType NoteProperty -Name "volume_group" -Value $volumeGroupRef
        if ($VMWare) {
            $body | Add-Member -MemberType NoteProperty -Name vmware_support -Value $true
        }
        if ($Description) {
            $body | Add-Member -MemberType NoteProperty -Name description -Value $Description
        }
        if ($ReadOnly) {
            $body | Add-Member -MemberType NoteProperty -Name read_only -Value $true
        }

        # POST returns nothing on success — submit and then poll the GET
        # until the new volume appears.

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $name -Get {
            Get-SDPVolume -name $name -k2context $k2context
        }

        return $results
    }
}
