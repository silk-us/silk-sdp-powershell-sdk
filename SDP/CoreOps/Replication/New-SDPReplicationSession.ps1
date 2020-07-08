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
        [parameter(Mandatory)]
        [int] $RPO,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    <#
        .SYNOPSIS

        .EXAMPLE 
        New-SDPReplicationSession -name testrep -volumeGroupName retest01 -replicationPeerName K2-5405 -retentionPolicyName Replication_Retention -externalRetentionPolicyName Replication_Retention -RPO 1200

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

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

