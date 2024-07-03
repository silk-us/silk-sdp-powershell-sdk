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

    <#
        .SYNOPSIS

        .EXAMPLE 

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/silk-us/silk-sdp-powershell-sdk

    #>
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