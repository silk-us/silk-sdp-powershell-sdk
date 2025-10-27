<#
    .SYNOPSIS
    Function for querying SDP system network ports

    .EXAMPLE 
    Get-SDPSystemNetPorts

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk

#>

function Get-SDPSystemNetPorts {
    param(
        [parameter()]
        [Alias("PortType")]
        [ValidateSet('dataport','mgmtport','ib')]
        [string] $port_type,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $pipeId,
        [parameter()]
        [string] $pipeName,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/net_ports"
    }
    
    process {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        return $results
    }
}