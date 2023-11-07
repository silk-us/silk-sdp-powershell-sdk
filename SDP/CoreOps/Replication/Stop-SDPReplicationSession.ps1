function Stop-SDPReplicationSession {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [switch] $wait,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'replication/sessions'
    }
    
    process {
        $session = Get-SDPReplicationSessions -name $name -k2context $k2context
        if ($session) {
            if ($session.state -ne 'suspended') {
                $errormsg = 'Please ensure replication session is currently "suspended"'
                return $errormsg | Write-Error
            }
            
            $o = New-Object psobject
            $o | Add-Member -MemberType NoteProperty -Name "state" -Value 'idle'

            $body = $o
            $subendpoint = $endpoint + '/' + $session.id

            try {
                $results = Invoke-SDPRestCall -endpoint $subendpoint -method PATCH -body $body -k2context $k2context 
            } catch {
                return $Error[0]
            }
            if ($wait) {
                while ($session.state -ne 'idle') {
                    $session = Get-SDPReplicationSessions -name $name -k2context $k2context
                    Start-Sleep -Seconds 2
                }
            }
            $results = Get-SDPReplicationSessions -name $name -k2context $k2context
            return $results
        }
    }
}