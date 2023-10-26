function Start-SDPReplicationSession {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'replication/sessions'
    }
    
    process {
        $session = Get-SDPReplicationSessions -name $name
        if ($session) {
            $o = New-Object psobject
            $o | Add-Member -MemberType NoteProperty -Name "state" -Value 'in_sync'

            $body = $o
            $endpoint = $endpoint + '/' + $session.id

            try {
                $results = Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $body -k2context $k2context -erroraction silentlycontinue
            } catch {
                return $Error[0]
            }
            return $results
        }
    }
}