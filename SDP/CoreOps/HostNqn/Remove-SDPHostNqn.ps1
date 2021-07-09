function Remove-SDPHostNqn {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Remove an existing host Nqn. 

        .EXAMPLE 
        Remove-SDPHostNqn -id 123

        .EXAMPLE 
        Get-SDPHostNqn -hostName LinuxHost03 | Remove-SDPHostNqn 
        
        .DESCRIPTION
        Use this function to remove an existing host Nqn using these examples. Accepts piped imput from Get-SDPHostNqn

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

    begin {
        $endpoint = 'host_nqns'
    }

    process {

        $hostObject = Get-SDPHostNqn -hostName $hostName

        ## Make the call
        $endpointURI = $endpoint + '/' + $hostObject.id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
        return $results
    }
}