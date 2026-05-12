function Stop-SDPReplicationSession {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [switch] $wait,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = 'replication/sessions'
    }

    process {
        $session = Get-SDPReplicationSessions -name $name -context $context
        if ($session) {
            if ($session.state -ne 'suspended') {
                $errormsg = 'Please ensure replication session is currently "suspended"'
                return $errormsg | Write-Error
            }

            if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
                $ConfirmPreference = 'None'
            }
            if ($PSCmdlet.ShouldProcess("SDPReplicationSession name=$name", 'Stop (transition to idle)')) {
                $o = New-Object psobject
                $o | Add-Member -MemberType NoteProperty -Name "state" -Value 'idle'

                $body = $o
                $subendpoint = $endpoint + '/' + $session.id

                try {
                    $results = Invoke-SDPRestCall -endpoint $subendpoint -method PATCH -body $body -context $context
                } catch {
                    return $Error[0]
                }
                if ($wait) {
                    while ($session.state -ne 'idle') {
                        $session = Get-SDPReplicationSessions -name $name -context $context
                        Start-Sleep -Seconds 2
                    }
                    Write-Progress -Completed -Activity $activityString
                }
                $results = Get-SDPReplicationSessions -name $name -context $context
                return $results
            }
        }
    }
}