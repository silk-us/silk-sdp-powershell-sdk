function Remove-SDPReplicationSession {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "replication/sessions" 
    }
    
    process {
        $session = Get-SDPReplicationSessions -name $name -k2context $k2context
        if ($session) {
            if ($session.state -ne 'idle') {
                $errormsg = 'Please ensure replication session is currently "idle"'
                return $errormsg | Write-Error
            }
            $subendpoint = $endpoint + '/' + $session.id
            
            try {
                $results = Invoke-SDPRestCall -endpoint $subendpoint -method DELETE -k2context $k2context
            } catch {
                return $Error[0]
            }
            return $results
        }
    }
}
