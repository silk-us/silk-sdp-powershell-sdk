function Get-SDPHost {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [Alias("hostGroup")]
        [string] $host_group,
        [parameter()]
        [int] $id,
        [parameter(Position=1)]
        [string] $name,
        [parameter()]
        [string] $type,
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
        $endpoint = "hosts"
    }
    
    process {
        if ($host_group) {
            Write-Verbose "host_group specified, parsing KDP Object"
            $PSBoundParameters.host_group = ConvertTo-SDPObjectPrefix -ObjectPath host_groups -ObjectID $host_group -nestedObject
        }

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        return $results
    }

}
