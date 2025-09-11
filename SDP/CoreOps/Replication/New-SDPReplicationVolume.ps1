function New-SDPReplicationVolume {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('pipeName')]
        [string] $volumeName,
        [parameter(Mandatory)]
        [string] $replicationSessionName,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'replication/peer_volumes'
    }

    process{
        ## Special Ops

        $volumeId = Get-SDPVolume -name $volumeName -k2context $k2context
        $sessionId = Get-SDPReplicationPeerArray -name $replicationSessionName -k2context $k2context

        $volumeId = Get-SDPVolume -name $volumeName -k2context $k2context
        $volumeObj = ConvertTo-SDPObjectPrefix -ObjectID $volumeId.id -ObjectPath 'volumes' -nestedObject 

        $sessionId = Get-SDPReplicationSessions -name $replicationSessionName -k2context $k2context
        $peerArrayPath = ConvertTo-SDPObjectPrefix -ObjectID $sessionId.id -ObjectPath 'replication/sessions' -nestedObject

        # Build the object
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "local_volume" -Value $volumeObj
        $o | Add-Member -MemberType NoteProperty -Name "replication_session" -Value $peerArrayPath

        # Make the call 

        $body = $o
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }
        
        return $body
    }
}

