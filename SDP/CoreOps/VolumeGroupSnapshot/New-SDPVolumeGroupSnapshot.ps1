function New-SDPVolumeGroupSnapshot {
    param(
        [parameter()]
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
        [string] $replicationSession,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'snapshots'
    }

    process{
        ## Special Ops

        if ($name -and $replicationSession) {
            Write-Verbose "You cannot specify a -name for replicated snapshots, -name parameter will not be applied." -Verbose
        }

        if (!$name -and !$replicationSession) {
            $name = $volumeGroupName + '-' + [DateTimeOffset]::Now.ToUnixTimeSeconds()
            Write-Verbose "No -name specified, using the name: $name" -Verbose
        }
        
        $volumeGroupObject = Get-SDPVolumeGroup -name $volumeGroupName -k2context $k2context
        $volumeGroupPath = ConvertTo-SDPObjectPrefix -ObjectPath 'volume_groups' -ObjectID $volumeGroupObject.id -nestedObject

        $retentionPolicyObject = Get-SDPRetentionPolicy -name $retentionPolicyName -k2context $k2context
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
