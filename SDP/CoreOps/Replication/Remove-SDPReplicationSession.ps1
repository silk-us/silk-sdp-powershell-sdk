function Remove-SDPReplicationSession {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "replication/sessions/" 
    }
    
    process {
        $session = Get-SDPReplicationSessions -name $name
        if ($session) {

            $endpoint = $endpoint + '/' + $session.id
            
            try {
                $results = Invoke-SDPRestCall -endpoint $endpoint -method DELETE -k2context $k2context
            } catch {
                return $Error[0]
            }
            return $results
        }
    }
}
