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
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPHostIqn {
    [CmdletBinding()]
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'host_iqns'
    }

    process {

        # Special Ops — locate the IQN record by host.

        $hostIqn = Get-SDPHostIqn -hostName $hostName -k2context $k2context -doNotResolve

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$($hostIqn.id)" -method DELETE -k2context $k2context
        return $results
    }
}
