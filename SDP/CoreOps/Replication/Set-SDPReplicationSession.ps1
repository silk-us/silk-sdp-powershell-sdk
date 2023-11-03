function Set-SDPReplicationSession {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [string] $newName,
        [parameter()]
        [int] $RPO,
        [parameter()]
        [string] $retentionPolicyName,
        [parameter()]
        [string] $externalRetentionPolicyName,
        [parameter()]
        [ValidateSet('mapped','readOnly')]
        [string] $targetExposure,
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

            ### Add parameter sets here
            if ($newName) {
                $o | Add-Member -MemberType NoteProperty -Name "name" -Value $newName
            }

            if ($RPO) {
                $o | Add-Member -MemberType NoteProperty -Name "rpo" -Value $RPO.ToString()
            }

            if ($retentionPolicyName) {
                $retentionPolicyId = Get-SDPRetentionPolicy -name $retentionPolicyName -k2context $k2context
                $retentionPolicypath = ConvertTo-SDPObjectPrefix -ObjectID $retentionPolicyId.id -ObjectPath 'retention_policies' -nestedObject
                $o | Add-Member -MemberType NoteProperty -Name "retention_policy" -Value $retentionPolicypath
            }

            if ($externalRetentionPolicyName) {
                $externalRetentionPolicyId = Get-SDPRetentionPolicy -name $externalRetentionPolicyName -k2context $k2context
                $externalRetentionPolicypath = ConvertTo-SDPObjectPrefix -ObjectID $externalRetentionPolicyId.id -ObjectPath 'retention_policies' -nestedObject
                $o | Add-Member -MemberType NoteProperty -Name "external_retention_policy" -Value $externalRetentionPolicypath
            }

            if ($targetExposure) {
                if ($targetExposure -eq 'mapped') {
                    $o | Add-Member -MemberType NoteProperty -Name "target_exposure" -Value 'Mapped - Not Exposed'
                } elseif ($targetExposure -eq 'readOnly') {
                    $o | Add-Member -MemberType NoteProperty -Name "target_exposure" -Value 'Read Only'
                }
            }

            $body = $o
            $endpoint = $endpoint + '/' + $session.id

            try {
                $results = Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $body -k2context $k2context -erroraction silentlycontinue
            } catch {
                return $Error[0]
            }
            $results = Get-SDPReplicationSessions -name $name -k2context $k2context
            return $results
        }
    }
}