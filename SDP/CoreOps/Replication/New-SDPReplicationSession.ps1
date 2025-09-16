<#
    .SYNOPSIS

    .EXAMPLE 
    New-SDPReplicationSession -name testrep -volumeGroupName retest01 -replicationPeerName K2-5405 -retentionPolicyName Replication_Retention -externalRetentionPolicyName Replication_Retention -RPO 1200

    .DESCRIPTION

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk

#>

function New-SDPReplicationSession {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [string] $volumeGroupName,
        [parameter(Mandatory)]
        [string] $replicationPeerName,
        [parameter(Mandatory)]
        [string] $retentionPolicyName,
        [parameter(Mandatory)]
        [string] $externalRetentionPolicyName,
        [parameter()]
        [switch] $mapped,
        [parameter()]
        [string] $replicationVolumeGroupName,
        [parameter(Mandatory)]
        [int] $RPO,
        [parameter()]
        [bool] $autoConfigurePeerVolumes = $true,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )


    begin {
        $endpoint = 'replication/sessions'
    }

    process{
        ## Special Ops

        $volumeGroupId = Get-SDPVolumeGroup -name $volumeGroupName
        $volumeGroupPath = ConvertTo-SDPObjectPrefix -ObjectID $volumeGroupId.id -ObjectPath 'volume_groups' -nestedObject

        $peerArrayId = Get-SDPReplicationPeerArray -name $replicationPeerName
        $peerArrayPath = ConvertTo-SDPObjectPrefix -ObjectID $peerArrayId.id -ObjectPath 'replication/peer_k2arrays' -nestedObject

        $retentionPolicyId = Get-SDPRetentionPolicy -name $retentionPolicyName
        $retentionPolicypath = ConvertTo-SDPObjectPrefix -ObjectID $retentionPolicyId.id -ObjectPath 'retention_policies' -nestedObject

        $externalRetentionPolicyId = Get-SDPRetentionPolicy -name $externalRetentionPolicyName
        $externalRetentionPolicypath = ConvertTo-SDPObjectPrefix -ObjectID $externalRetentionPolicyId.id -ObjectPath 'retention_policies' -nestedObject

        
        # Build the object
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "rpo" -Value $RPO.ToString()
        $o | Add-Member -MemberType NoteProperty -Name "replication_peer_k2array" -Value $peerArrayPath
        $o | Add-Member -MemberType NoteProperty -Name "local_volume_group" -Value $volumeGroupPath
        $o | Add-Member -MemberType NoteProperty -Name "retention_policy" -Value $retentionPolicypath
        $o | Add-Member -MemberType NoteProperty -Name "external_retention_policy" -Value $externalRetentionPolicypath
        $o | Add-Member -MemberType NoteProperty -Name "auto_configure_peer_volumes" -Value $autoConfigurePeerVolumes
        if ($mapped) {
            $o | Add-Member -MemberType NoteProperty -Name "target_exposure" -Value 'Mapped - Not Exposed'
        } else {
            $o | Add-Member -MemberType NoteProperty -Name "target_exposure" -Value 'Read Only'
        }
        if ($replicationVolumeGroupName) {
            $o | Add-Member -MemberType NoteProperty -Name "replication_peer_volume_group_name" -Value $replicationVolumeGroupName
        } 
       


        # Make the call 

        $body = $o
        
        try {
            $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        } catch {
            return $Error[0]
        }
        $results = Get-SDPReplicationSessions -name $name -k2context $k2context
        return $results
    }
}

