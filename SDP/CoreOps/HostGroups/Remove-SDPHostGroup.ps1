function Remove-SDPHostGroup {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Removes any existing Host Group. 

        .EXAMPLE 
        Remove-SDPHostGroup -name HostGroup01

        .EXAMPLE 
        Get-SDPHostGroup | where {$_.name -like "LinuxHosts*"} | Remove-SDPHostGroup 

        .DESCRIPTION
        Use this function to remove any existing Host Group. This command accepts piped input from a Get-SDPHostGroup query. 

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = 'host_groups'
    }

    process {
        # Special Ops
        if ($name -and !$id) {
            $id = (Get-SDPHostGroup -name $name -k2context $k2context).id
        }

        # Make the call
        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
        return $results
    }
}