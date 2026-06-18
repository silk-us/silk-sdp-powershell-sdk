<#
    .SYNOPSIS
    Removes a static route from the SDP.

    .DESCRIPTION
    Deletes the static route identified by `id` from the Silk Data Pod's
    management network. Accepts piped input from Get-SDPStaticRoute.

    .PARAMETER id
    The unique identifier of the static route to remove.

    .PARAMETER context
    Specifies the K2 context to use for authentication. Defaults to
    'sdpconnection'.

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

    begin {
        $endpoint = 'static_routes'
    }

    process {
        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPStaticRoute id=$id", 'Remove')) {
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -context $context
            return $results
        }
    }
}
