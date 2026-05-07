function Remove-SDPHostGroupMapping {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
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
        https://github.com/silk-us/silk-sdp-powershell-sdk

    #>

    begin {
        $endpoint = 'mappings'
    }

    process {
        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPHostGroupMapping id=$id", 'Remove')) {
            ## Make the call
            $endpointURI = $endpoint + '/' + $id
            $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
            return $results
        }
    }
}