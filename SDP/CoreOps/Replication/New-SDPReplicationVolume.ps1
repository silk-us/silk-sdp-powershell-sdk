<#
    .SYNOPSIS
    Create replication peer volume declarations for newly created replication sessions that included -autoConfigurePeerVolumes $false as a parameter. 

    .EXAMPLE 
    In this example I have a volume group named test01-vg that contains 2 volumes named test01-vol-1 and test01-vol-2. I established a replication session named testrep01 for this volume group that included -autoConfigurePeerVolumes $false as a parameter. 
    
    I want the volumes to retain their same name on the replication peer. 

    Before I start this newly created session (testrep01) I declare the 2 volumes like so:

    New-SDPReplicationVolume -name test01-vol-1 -volumeName test01-vol-1 -replicationSessionName testrep01
    New-SDPReplicationVolume -name test01-vol-2 -volumeName test01-vol-2 -replicationSessionName testrep01

    Then I am able to start the newly created replication session using Start-SDPReplicationSession. 

    .DESCRIPTION

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk

#>

function New-SDPReplicationVolume {
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('pipeName')]
        [string] $volumeName,
        [parameter(Mandatory)]
        [string] $name,
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
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        } catch {
            return $Error[0]
        }
        
        # return $body
    }
}

