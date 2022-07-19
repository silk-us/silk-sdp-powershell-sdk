function New-SDPChapUser {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $chapCredentials,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "host_auth_profiles"
    }

    process {

        # Special Ops
        
        $username = $chapCredentials.UserName
        $password = $chapCredentials.GetNetworkCredential().Password

        # Query 

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name 'name' -Value $name
        $o | Add-Member -MemberType NoteProperty -Name 'username' -Value $username
        $o | Add-Member -MemberType NoteProperty -Name 'password' -Value $password
        $o | Add-Member -MemberType NoteProperty -Name 'type' -Value 'CHAP'

        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $o -k2context $k2context

        return $results
    }
}