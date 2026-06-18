function Remove-SDPHostPwwn {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $context = 'sdpconnection'
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
        https://github.com/silk-us/silk-sdp-powershell-sdk

    #>

    begin {
        $endpoint = 'host_fc_ports'
    }

    process {
        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPHostPwwn id=$id", 'Remove')) {
            ## Make the call
            $endpointURI = $endpoint + '/' + $id
            $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -context $context
            return $results
        }
    }
}