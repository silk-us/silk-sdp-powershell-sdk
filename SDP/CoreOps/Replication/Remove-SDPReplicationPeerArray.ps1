function Remove-SDPReplicationPeerArray {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    ## Special Ops
    begin {
        $endpoint = 'replication/peer_k2arrays'
    }

    process {
        ## Make the call
        $subendpoint = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $subendpoint -method DELETE -k2context $k2context
        return $results
    }
}