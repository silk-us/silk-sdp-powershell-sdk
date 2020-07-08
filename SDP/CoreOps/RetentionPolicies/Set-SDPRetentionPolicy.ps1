function Set-SDPRetentionPolicy {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $snapshotCount,
        [parameter()]
        [int] $weeks,
        [parameter()]
        [int] $days,
        [parameter()]
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

        if ($name) {
            $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        }
        if ($snapshotCount) {
            $o | Add-Member -MemberType NoteProperty -Name "num_snapshots" -Value $snapshotCount.ToString()
        }
        if ($weeks) {
            $o | Add-Member -MemberType NoteProperty -Name "weeks" -Value $weeks.ToString()
        }
        if ($days) {
            $o | Add-Member -MemberType NoteProperty -Name "days" -Value $days.ToString()
        }
        if ($hours) {
            $o | Add-Member -MemberType NoteProperty -Name "hours" -Value $hours.ToString()
        }
 

        $body = $o

        ## Make the call
        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method PATCH -body $body -k2context $k2context 
        return $results
    }
}
