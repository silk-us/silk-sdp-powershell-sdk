function Get-SDPHostGroup {
    param(
        [parameter()]
        [int] $id,
        [parameter(position=1)]
        [string] $name,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Use this function to query for Host Groups.

        .EXAMPLE 
        Get-SDPHostGroup -name HostGroup01

        .DESCRIPTION
        This function allows for the query for any host group defined on the desired SDP.

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = "host_groups"
    }

    process {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        return $results
    }
}
