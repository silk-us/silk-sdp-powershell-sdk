function Remove-SDPVolume {
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

        .EXAMPLE 

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>    

    begin {
        $endpoint = "volumes"
    }

    process {

        # Special Ops

        if ($name) {
            $volname = Get-SDPVolume -name $name -k2context $k2context
            if (!$volname) {
                return "No volume with name $name exists."
            } elseif (($volname | measure-object).count -gt 1) {
                return "Too many replies with $name"
            } else {
                $id = $volname.id
            }
        }

        # Call
        
        $endpointURI = $endpoint + '/' + $id
        Write-Verbose "Removing volume with id $id"
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context

        return $results
    }
}
