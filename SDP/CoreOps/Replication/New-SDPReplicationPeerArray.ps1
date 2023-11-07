function New-SDPReplicationPeerArray {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [alias('remoteHost')]
        [string] $mgmt_host,
        [parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $localCredential,
        [parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $remoteCredential,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'replication/peer_k2arrays'
    }

    process{
        ## Special Ops

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "mgmt_host" -Value $mgmt_host
        $o | Add-Member -MemberType NoteProperty -Name "username" -Value $localCredential.UserName
        $o | Add-Member -MemberType NoteProperty -Name "password" -Value $localCredential.GetNetworkCredential().password
        $o | Add-Member -MemberType NoteProperty -Name "local_username" -Value $remoteCredential.UserName
        $o | Add-Member -MemberType NoteProperty -Name "local_password" -Value $remoteCredential.GetNetworkCredential().password


        # Make the call 

        $body = $o
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        } catch {
            return $Error[0]
        }
        
        $results = Get-SDPReplicationPeerArray -name $name -k2context $k2context
        return $results
    }
}

