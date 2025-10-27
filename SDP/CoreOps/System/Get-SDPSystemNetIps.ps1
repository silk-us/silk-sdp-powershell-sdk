    <#
        .SYNOPSIS
        Function for querying SDP system network IPs

        .EXAMPLE 
        Get-SDPSystemNetIps 

        .EXAMPLE 
        Get-SDPSystemNetPorts | Where-Object {$_.name -match "dataport01"} | Get-SDPSystemNetIps

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://github.com/silk-us/silk-sdp-powershell-sdk

    #>

function Get-SDPSystemNetIps {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string] $portID,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/net_ips"
    }
    
    process {
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -k2context $k2context
        if ($portID) {
            $ref = ConvertTo-SDPObjectPrefix -ObjectID $portID -ObjectPath 'system/net_ports'
            $results = $results | Where-Object {$_.net_port.ref -contains $ref}
        }
        
        return $results
    }
}
