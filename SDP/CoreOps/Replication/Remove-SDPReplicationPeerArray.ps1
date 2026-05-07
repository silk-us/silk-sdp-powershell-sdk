function Remove-SDPReplicationPeerArray {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    ## Special Ops
    begin {
        $endpoint = 'replication/peer_k2arrays'
    }

    process {
        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPReplicationPeerArray id=$id", 'Remove')) {
            ## Make the call
            $subendpoint = $endpoint + '/' + $id
            $results = Invoke-SDPRestCall -endpoint $subendpoint -method DELETE -k2context $k2context
            return $results
        }
    }
}