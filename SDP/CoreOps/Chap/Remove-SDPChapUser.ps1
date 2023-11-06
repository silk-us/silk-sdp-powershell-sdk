function Remove-SDPChapUser {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [int] $id,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "host_auth_profiles"
    }

    process {

        # Special Ops
        if ($name) {
            $id = (Get-SDPChapUser -name $name -k2context $k2context).id
        }
        # Query 

        $endpoint = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpoint -method DELETE -k2context $k2context

        return $results
    }
}