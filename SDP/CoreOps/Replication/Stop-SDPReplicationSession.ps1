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
        $session = Get-SDPReplicationSessions -name $name
        if ($session) {
            if ($session.state -ne 'suspended') {
                $errormsg = 'Please ensure replication session is currently "suspended"'
                return $errormsg | Write-Error
            }
            
            $o = New-Object psobject
            $o | Add-Member -MemberType NoteProperty -Name "state" -Value 'idle'

            $body = $o
            $endpoint = $endpoint + '/' + $session.id

            try {
                $results = Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $body -k2context $k2context -erroraction silentlycontinue
            } catch {
                return $Error[0]
            }
            if ($wait) {
                while ($session.state -ne 'idle') {
                    $session = Get-SDPReplicationSessions -name $name
                    Start-Sleep -Seconds 2
                }
            }
            $results = Get-SDPReplicationSessions -name $name
            return $results
        }
    }
}