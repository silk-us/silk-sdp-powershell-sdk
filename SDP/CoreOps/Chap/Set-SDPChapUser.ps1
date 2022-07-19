function Set-SDPChapUser {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [int] $id,
        [parameter()]
        [System.Management.Automation.PSCredential] $chapCredentials,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "host_auth_profiles"
    }

    process {

        # Special Ops
        if ($name) {
            $id = (Get-SDPChapUser -name $name).id
        }

        $username = $chapCredentials.UserName
        $password = $chapCredentials.GetNetworkCredential().Password

        # Query 

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name 'new_username' -Value $username
        $o | Add-Member -MemberType NoteProperty -Name 'new_password' -Value $password

        $endpoint = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $o -k2context $k2context

        return $results

    }
}