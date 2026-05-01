<#
    .SYNOPSIS
    Sets the default SDP context for subsequent cmdlet calls.

    .DESCRIPTION
    Promotes the named context variable to the global `k2rfconnection`
    so that other Get-SDP* / New-SDP* / etc. cmdlets that default to
    `-k2context k2rfconnection` use it without an explicit parameter.

    Returns the result of a `system/state` GET against the new default
    context as a sanity check that the credentials still work.

    .PARAMETER k2context
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
        [string] $k2context = 'k2rfconnection'
    )

    $contextVar = Get-Variable -Name $k2context

    $defaultContext = New-Object psobject
    $defaultContext | Add-Member -MemberType NoteProperty -Name 'credentials' -Value $contextVar.Value.credentials
    $defaultContext | Add-Member -MemberType NoteProperty -Name 'K2Endpoint'  -Value $contextVar.Value.K2Endpoint

    Set-Variable -Name 'k2rfconnection' -Value $defaultContext -Scope Global

    $results = Invoke-SDPRestCall -endpoint 'system/state' -method GET -k2context 'k2rfconnection'

    return $results
}
