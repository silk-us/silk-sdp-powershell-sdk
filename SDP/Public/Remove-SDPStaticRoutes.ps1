<#
    .SYNOPSIS
    Removes a static route from the SDP.

    .DESCRIPTION
    Deletes the static route identified by `id` from the Silk Data Pod's
    management network. Accepts piped input from Get-SDPStaticRoute.

    .PARAMETER id
    The unique identifier of the static route to remove.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Remove-SDPStaticRoute -id 4

    .EXAMPLE
    Get-SDPStaticRoute | Remove-SDPStaticRoute

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPStaticRoute {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'static_routes'
    }

    process {
        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
        return $results
    }
}
