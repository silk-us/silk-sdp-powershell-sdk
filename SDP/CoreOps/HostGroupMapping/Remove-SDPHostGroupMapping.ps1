function Remove-SDPHostGroupMapping {
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
        Remove-SDPHostGroupMapping -id 432

        .EXAMPLE 
        Get-SDPHostGroupMapping -hostGroupName HG01 | Remove-SDPHostGroupMapping 
        
        .DESCRIPTION
        Use this function to remove an existing host group mapping using these examples. Accepts piped imput from Get-SDPHostGroupMapping

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