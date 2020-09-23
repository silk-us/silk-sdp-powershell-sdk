function Get-SDPVolumeStats {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [int] $id,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    <#
        .SYNOPSIS

        .EXAMPLE    
            Get-SDPVolume -name TestVOL | Get-SDPVolumeStats

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

    begin {
        $endpoint = "stats/volumes"
    }

    process {
        # Special Ops

        if ($id) {
            Remove-variable endpoint
            $endpoint = 'stats/volumes/' + $id
        }

        # Query 

        Write-Verbose "Collecting Stats for $endpoint"
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -k2context $k2context 
        return $results
    }
}
