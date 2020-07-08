function Set-SDPHostPwwn {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $pwwn,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'host_fc_ports'
    }

    process{
        ## Special Ops

        $hostid = Get-SDPHost -name $hostname
        $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath 'hosts' -ObjectID $hostid.id -nestedObject

        # Build the Object
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "pwwn" -Value $pwwn
        $o | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        
        $body = $o

        ## Make the call
        # $endpointURI = $endpoint + '/' + $hostid.id
        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        return $results
    }
}