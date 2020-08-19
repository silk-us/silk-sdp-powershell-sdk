function New-SDPVgCapacityPolicy {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [int] $warningThreshold,
        [parameter(Mandatory)]
        [int] $errorThreshold,
        [parameter(Mandatory)]
        [int] $criticalThreshold,
        [parameter(Mandatory)]
        [int] $fullThreshold,
        [parameter(Mandatory)]
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
        $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "warning_threshold" -Value $warningThreshold
        $o | Add-Member -MemberType NoteProperty -Name "error_threshold" -Value $errorThreshold
        $o | Add-Member -MemberType NoteProperty -Name "critical_threshold" -Value $criticalThreshold
        $o | Add-Member -MemberType NoteProperty -Name "full_threshold" -Value $fullThreshold
        $o | Add-Member -MemberType NoteProperty -Name "snapshot_overhead_threshold" -Value $snapshotOverheadThreshold

        if ($size) {
            $o | Add-Member -MemberType NoteProperty -Name "num_snapshots" -Value $snapshotCount
        }

        # Make the call 

        $body = $o
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        } catch {
            return $Error[0]
        }
        
        return $body
    }
}

