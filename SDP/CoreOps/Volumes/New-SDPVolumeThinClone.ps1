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

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

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
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $volumeName,
        [parameter(Mandatory)]
        [string] $volumeGroupName,
        [parameter(Mandatory)]
        [string] $snapshotName,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    begin {
        $endpoint = "volumes"
    }

    process {
        $volumeGroup = Get-SDPVolumeGroup -name $volumeGroupName -k2context $k2context
        $volumeGroupRef = ConvertTo-SDPObjectPrefix -ObjectID $volumeGroup.id -ObjectPath volume_groups -nestedObject
        
        $volume = Get-SDPVolume -name $volumeName -k2context $k2context
        $volumeRef = ConvertTo-SDPObjectPrefix -ObjectID $volume.id -ObjectPath volumes -nestedObject
        
        $snapshot = Get-SDPVolumeGroupSnapshot -k2context $k2context | Where-Object {$_.name -match $snapshotName} 
        $snapshotRef  = ConvertTo-SDPObjectPrefix -ObjectID $snapshot.id -ObjectPath snapshots -nestedObject
        
        
        $o = new-object psobject
        $o | Add-Member -MemberType NoteProperty -Name volume_group -Value $volumeGroupRef 
        $o | Add-Member -MemberType NoteProperty -Name source_snapshot -Value $snapshotRef
        $o | Add-Member -MemberType NoteProperty -Name name -Value $name
        $o | Add-Member -MemberType NoteProperty -Name is_thin_clone -Value 'true'
        $o | Add-Member -MemberType NoteProperty -Name source_volume -Value $volumeRef

        $body = $o 

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }
        
        $results = Get-SDPVolume -name $name -k2context $k2context
        while (!$results) {
            Write-Verbose " --> Waiting on volume $name"
            $results = Get-SDPVolume -name $name -k2context $k2context
            Start-Sleep 1
        }

        return $results
    }
}