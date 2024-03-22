function New-SDPVolumeView {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [alias('pipeName')]
        [string] $snapshotName,
        [parameter(Mandatory)]
        [string] $retentionPolicyName,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        Write-Verbose "the cmdlet New-SDPVolumeView has been replaced by New-SDPVolumeGroupView and will cease to function in a future release." -Verbose
        $endpoint = 'snapshots'
    }

    process{
        ## Special Ops
        $snapshotObject = Get-SDPVolumeGroupSnapshot -name $snapshotName -k2context $k2context
        $snapshotPath = ConvertTo-SDPObjectPrefix -ObjectPath 'snapshots' -ObjectID $snapshotObject.id -nestedObject

        $retentionPolicyObject = Get-SDPRetentionPolicy -name $retentionPolicyName -k2context $k2context
        $retentionPolicyPath = ConvertTo-SDPObjectPrefix -ObjectPath 'retention_policies' -ObjectID $retentionPolicyObject.id -nestedObject

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "short_name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "source" -Value $snapshotPath
        $o | Add-Member -MemberType NoteProperty -Name "retention_policy" -Value $retentionPolicyPath
        $o | Add-Member -MemberType NoteProperty -Name "is_auto_deleteable" -Value $true
        $o | Add-Member -MemberType NoteProperty -Name "is_exposable" -Value $true


        $body = $o

        ## Make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        return $results
    }
}
