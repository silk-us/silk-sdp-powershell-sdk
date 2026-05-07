function Remove-SDPReplicationSession {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [switch] $Force,
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
            if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
                $ConfirmPreference = 'None'
            }
            if ($PSCmdlet.ShouldProcess("SDPReplicationSession name=$name id=$($session.id)", 'Remove')) {
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
}
