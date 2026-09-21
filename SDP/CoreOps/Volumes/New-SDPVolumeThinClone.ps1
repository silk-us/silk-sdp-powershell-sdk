<#
    .SYNOPSIS
    Creates a thin clone of a volume from a snapshot.

    .DESCRIPTION
    Creates a space-efficient thin clone volume from an existing snapshot. The thin clone shares blocks with the source volume until modifications are made.

    .PARAMETER name
    The name for the new thin clone volume.

    .PARAMETER volumeName
    The name of the source volume to clone. Accepts piped input from Get-SDPVolume.

    .PARAMETER volumeGroupName
    The name of the volume group where the thin clone will be created.

    .PARAMETER snapshotName
    The name of the snapshot to use as the clone source.

    .PARAMETER context
    Specifies the K2 context to use for authentication. Defaults to 'sdpconnection'.

    .EXAMPLE
    New-SDPVolumeThinClone -name "Vol01-Clone" -volumeName "Vol01" -volumeGroupName "VG01" -snapshotName "Snap01"
    Creates a thin clone named "Vol01-Clone" from the snapshot "Snap01".

    .EXAMPLE
    Get-SDPVolume -name "Vol01" | New-SDPVolumeThinClone -name "Vol01-TestClone" -volumeGroupName "VG01" -snapshotName "Snap01"
    Creates a thin clone using piped volume input.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://www.github.com/silk-us/silk-sdp-powershell-sdk
#>
function New-SDPVolumeThinClone {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ValidateLength(0, 42)]
        [string] $name,
        # piped SDPVolume lands here
        [parameter(ValueFromPipeline)]
        [object] $InputObject,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $volumeName,
        [parameter(Mandatory)]
        [string] $volumeGroupName,
        [parameter(Mandatory)]
        [string] $snapshotName,
        [parameter()]
        [string] $context = "sdpconnection"
    )
    begin {
        $endpoint = "volumes"
    }

    process {
        if ($InputObject -and $InputObject.GetType().Name -ne 'SDPVolume') {
            throw "New-SDPVolumeThinClone accepts pipeline input only from SDPVolume; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $volumeName = $InputObject.name
            if (-not $PSBoundParameters.ContainsKey('context')) {
                $context = $InputObject.context
            }
        }
        if (!$volumeName) {
            Write-Error "Specify -volumeName or pipe in a volume."
            return
        }

        $volumeGroup = Get-SDPVolumeGroup -name $volumeGroupName -context $context -doNotResolve
        if (!$volumeGroup) {
            Write-Error "No volume group named $volumeGroupName exists."
            return
        }
        $volumeGroupRef = ConvertTo-SDPObjectPrefix -ObjectID $volumeGroup.id -ObjectPath volume_groups -nestedObject

        $volume = Get-SDPVolume -name $volumeName -context $context -doNotResolve
        if (!$volume) {
            Write-Error "No volume named $volumeName exists."
            return
        }
        $volumeRef = ConvertTo-SDPObjectPrefix -ObjectID $volume.id -ObjectPath volumes -nestedObject

        # full vg:short_name or just the short name, same as New-SDPVolumeGroupView
        if ($snapshotName -match ':') {
            $snapshot = Get-SDPVolumeGroupSnapshot -name $snapshotName -context $context -doNotResolve
        } else {
            $snapshot = Get-SDPVolumeGroupSnapshot -short_name $snapshotName -context $context -doNotResolve
        }
        # $snapshot = Get-SDPVolumeGroupSnapshot -context $context | Where-Object {$_.name -match $snapshotName}
        if (!$snapshot) {
            Write-Error "No snapshot found matching $snapshotName."
            return
        }
        if (($snapshot | Measure-Object).Count -gt 1) {
            Write-Error "Multiple snapshots match '$snapshotName'. Use the full vg:short_name."
            return
        }
        $snapshotRef  = ConvertTo-SDPObjectPrefix -ObjectID $snapshot.id -ObjectPath snapshots -nestedObject


        $o = new-object psobject
        $o | Add-Member -MemberType NoteProperty -Name volume_group -Value $volumeGroupRef
        $o | Add-Member -MemberType NoteProperty -Name source_snapshot -Value $snapshotRef
        $o | Add-Member -MemberType NoteProperty -Name name -Value $name
        $o | Add-Member -MemberType NoteProperty -Name is_thin_clone -Value 'true'
        $o | Add-Member -MemberType NoteProperty -Name source_volume -Value $volumeRef

        $body = $o

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -context $context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $name -Get {
            Get-SDPVolume -name $name -context $context
        }

        return $results
    }
}