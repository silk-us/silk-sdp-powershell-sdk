function Remove-SDPHostMapping {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Remove an existing host mapping. 

        .EXAMPLE 
        Remove-SDPHostMapping -id 432

        .EXAMPLE 
        Get-SDPHostMapping -hostName LinuxHost03 | Remove-SDPHostMapping 
        
        .DESCRIPTION
        Use this function to remove an existing host mapping using these examples. Accepts piped imput from Get-SDPHostMapping

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

    begin {
        $endpoint = 'mappings'
    }

    process {
        ## Make the call
        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
        return $results
    }
}