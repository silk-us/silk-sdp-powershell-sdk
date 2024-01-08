function Get-SDPHostChapUser {
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS

        .EXAMPLE 

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = "host_auth_profile_mappers"
    }
    
    process {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        return $results
    }

}
