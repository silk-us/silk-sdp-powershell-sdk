function Start-SDPReplicationSession {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        # [parameter()]
        # [switch] $wait,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'replication/sessions'
    }
    
    process {
        $session = Get-SDPReplicationSessions -name $name -k2context $k2context
        if ($session) {
            $o = New-Object psobject
            $o | Add-Member -MemberType NoteProperty -Name "state" -Value 'in_sync'

            $body = $o
            $subendpoint = $endpoint + '/' + $session.id

            try {
                $results = Invoke-SDPRestCall -endpoint $subendpoint -method PATCH -body $body -k2context $k2context -timeOut 60
            } catch {
                return $Error[0]
            }
            <#
            if ($wait) {
                while ($session.state -ne 'in_sync') {
                    while ($session.current_snapshot_progress -lt 100) {
                        $activityString = "Starting replication session " + $name + " - " + $session.estimated_remaining_time + " secs"
                        Write-Progress -PercentComplete $session.current_snapshot_progress -Activity $activityString
                        Start-Sleep -Seconds 2
                        $session = Get-SDPReplicationSessions -name $name -k2context $k2context
                    }
                    Write-Progress -Completed -Activity $activityString
                }
            }
            #>
            $results = Get-SDPReplicationSessions -name $name -k2context $k2context
            return $results
        }
    }
}