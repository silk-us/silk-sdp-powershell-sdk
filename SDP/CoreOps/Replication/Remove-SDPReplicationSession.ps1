function Remove-SDPReplicationSession {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $context = "sdpconnection"
    )

    begin {
        $endpoint = "replication/sessions"
    }

    process {
        $session = Get-SDPReplicationSessions -name $name -context $context
        if ($session) {
            if ($session.state -ne 'idle') {
                $errormsg = 'Please ensure replication session is currently "idle"'
                return $errormsg | Write-Error
            }
            if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
                $ConfirmPreference = 'None'
            }
            if ($PSCmdlet.ShouldProcess("SDPReplicationSession name=$name id=$($session.id)", 'Remove')) {
                $subendpoint = $endpoint + '/' + $session.id

                try {
                    $results = Invoke-SDPRestCall -endpoint $subendpoint -method DELETE -context $context
                } catch {
                    return $Error[0]
                }
                return $results
            }
        }
    }
}
