function Remove-SDPHostPwwn {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Remove an existing host Pwwn. 

        .EXAMPLE 
        Remove-SDPHostPwwn -id 123

        .EXAMPLE 
        Get-SDPHostPwwn -hostName LinuxHost03 | Remove-SDPHostPwwn 
        
        .DESCRIPTION
        Use this function to remove an existing host Pwwn using these examples. Accepts piped imput from Get-SDPHostPwwn

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

    begin {
        $endpoint = 'host_fc_ports'
    }

    process {
        ## Make the call
        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
        return $results
    }
}