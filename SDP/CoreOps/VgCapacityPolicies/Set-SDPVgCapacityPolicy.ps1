function Set-SDPVgCapacityPolicy {
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $warningThreshold,
        [parameter()]
        [int] $errorThreshold,
        [parameter()]
        [int] $criticalThreshold,
        [parameter()]
        [int] $fullThreshold,
        [parameter()]
        [int] $snapshotOverheadThreshold,
        [parameter()]
        [int] $snapshotCount,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "vg_capacity_policies"
    }

    process{
        ## Special Ops

        $o = New-Object psobject
        if ($name) {
            $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        }
        if ($warningThreshold) {        
            $o | Add-Member -MemberType NoteProperty -Name "warning_threshold" -Value $warningThreshold
        }
        if ($criticalThreshold) {     
            $o | Add-Member -MemberType NoteProperty -Name "error_threshold" -Value $criticalThreshold
        }
        if ($) {     
            $o | Add-Member -MemberType NoteProperty -Name "critical_threshold" -Value $criticalThreshold
        }
        if ($fullThreshold) {     
            $o | Add-Member -MemberType NoteProperty -Name "full_threshold" -Value $fullThreshold
        }
        if ($snapshotOverheadThreshold) {     
            $o | Add-Member -MemberType NoteProperty -Name "snapshot_overhead_threshold" -Value $snapshotOverheadThreshold
        }
        if ($size) {
            $o | Add-Member -MemberType NoteProperty -Name "num_snapshots" -Value $snapshotCount
        }

        # Make the call 

        $body = $o
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $body -k2context $k2context 
        } catch {
            return $Error[0]
        }
        
        return $body
    }
}

