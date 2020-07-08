function New-SDPRetentionPolicy {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [int] $snapshotCount,
        [parameter(Mandatory)]
        [int] $weeks,
        [parameter(Mandatory)]
        [int] $days,
        [parameter(Mandatory)]
        [int] $hours,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "retention_policies"
    }

    process{
        ## Special Ops

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "num_snapshots" -Value $snapshotCount.ToString()
        $o | Add-Member -MemberType NoteProperty -Name "weeks" -Value $weeks.ToString()
        $o | Add-Member -MemberType NoteProperty -Name "days" -Value $days.ToString()
        $o | Add-Member -MemberType NoteProperty -Name "hours" -Value $hours.ToString()

        $body = $o

        ## Make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        return $results
    }
}
