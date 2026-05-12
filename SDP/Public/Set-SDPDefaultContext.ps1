<#
    .SYNOPSIS
    Sets the default SDP context for subsequent cmdlet calls.

    .DESCRIPTION
    Promotes the named context variable to the global `sdpconnection`
    so that other Get-SDP* / New-SDP* / etc. cmdlets that default to
    `-context sdpconnection` use it without an explicit parameter.

    Returns the result of a `system/state` GET against the new default
    context as a sanity check that the credentials still work.

    .PARAMETER context
    The name of an existing context variable to promote to default.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPDefaultContext {
    [CmdletBinding()]
    param(
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    $contextVar = Get-Variable -Name $context

    $defaultContext = New-Object psobject
    $defaultContext | Add-Member -MemberType NoteProperty -Name 'credentials' -Value $contextVar.Value.credentials
    $defaultContext | Add-Member -MemberType NoteProperty -Name 'K2Endpoint'  -Value $contextVar.Value.K2Endpoint

    Set-Variable -Name 'sdpconnection' -Value $defaultContext -Scope Global

    $results = Invoke-SDPRestCall -endpoint 'system/state' -method GET -context 'sdpconnection'

    return $results
}
