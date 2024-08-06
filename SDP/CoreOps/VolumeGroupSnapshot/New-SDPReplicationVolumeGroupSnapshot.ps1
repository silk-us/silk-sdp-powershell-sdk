function New-SDPReplicationVolumeGroupSnapshot {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [alias('pipeName')]
        [string] $volumeGroupName,
        [parameter()]
        [switch] $deletable,
        [parameter()]
        [switch] $exposable,
        [parameter(Mandatory)]
        [string] $replicationSession,
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

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "short_name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "source" -Value $volumeGroupPath
        if ($deletable) {
            $o | Add-Member -MemberType NoteProperty -Name "is_auto_deleteable" -Value $true
        }
        if ($exposable) {
            $o | Add-Member -MemberType NoteProperty -Name "is_exposable" -Value $true
        }
        if ($replicationSession) {
            $session = Get-SDPReplicationSessions -name $replicationSession -k2context $k2context
            $sessionObj = ConvertTo-SDPObjectPrefix -ObjectPath 'replication/sessions' -ObjectID $session.id -nestedObject
            $o | Add-Member -MemberType NoteProperty -Name "replication_session" -Value $sessionObj
        }

        $body = $o

        ## Make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        return $results
    }
}
