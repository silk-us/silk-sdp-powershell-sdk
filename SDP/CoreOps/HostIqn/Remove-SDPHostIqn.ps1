function Remove-SDPHostIqn {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Remove an existing host iqn. 

        .EXAMPLE 
        Remove-SDPHostIqn -id 123

        .EXAMPLE 
        Get-SDPHostIqn -hostName LinuxHost03 | Remove-SDPHostIqn 
        
        .DESCRIPTION
        Use this function to remove an existing host iqn using these examples. Accepts piped imput from Get-SDPHostIqn

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

    begin {
        $endpoint = 'host_iqns'
    }

    process {

        $hostObject = Get-SDPHostIqn -hostName $hostName -k2context $k2context

        ## Make the call
        $endpointURI = $endpoint + '/' + $hostObject.id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
        return $results
    }
}