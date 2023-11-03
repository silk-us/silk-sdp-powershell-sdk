function New-SDPVolumeGroupSnapshot {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [alias('pipeName')]
        [string] $volumeGroupName,
        [parameter(Mandatory)]
        [string] $retentionPolicyName,
        [parameter()]
        [switch] $deletable,
        [parameter()]
        [switch] $exposable,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'snapshots'
    }

    process{
        ## Special Ops
        $volumeGroupObject = Get-SDPVolumeGroup -name $volumeGroupName -k2context $k2context
        $volumeGroupPath = ConvertTo-SDPObjectPrefix -ObjectPath 'volume_groups' -ObjectID $volumeGroupObject.id -nestedObject

        $retentionPolicyObject = Get-SDPRetentionPolicy -name $retentionPolicyName
        $retentionPolicyPath = ConvertTo-SDPObjectPrefix -ObjectPath 'retention_policies' -ObjectID $retentionPolicyObject.id -nestedObject

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "short_name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "source" -Value $volumeGroupPath
        $o | Add-Member -MemberType NoteProperty -Name "retention_policy" -Value $retentionPolicyPath
        if ($deletable) {
            $o | Add-Member -MemberType NoteProperty -Name "is_auto_deleteable" -Value $true
        }
        if ($exposable) {
            $o | Add-Member -MemberType NoteProperty -Name "is_exposable" -Value $true
        }

        $body = $o

        ## Make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        return $results
    }
}
