function Get-SDPDNSServers {
    param(
        [parameter()]
        [string] $k2context = "k2rfconnection"
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
        $endpoint = "system/partial_system_parameters"
    }

    process {
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method GET -k2context $k2context -erroraction silentlycontinue | select dns_*
        } catch {
            return $Error[0]
        }
        
        return $results
    }

}