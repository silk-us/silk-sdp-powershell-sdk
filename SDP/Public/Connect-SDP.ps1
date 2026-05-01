<#
    .SYNOPSIS
    Connects you to an SDP instance.

    .DESCRIPTION
    Establishes a session to an existing SDP. The credential and endpoint are
    stored in a global variable named by -k2context (default
    'k2rfconnection') so subsequent SDP cmdlets can pick them up. The session
    only lives for the current PowerShell process.

    .PARAMETER server
    Management IP or DNS name for the SDP console.

    .PARAMETER credentials
    A PSCredential to authenticate against the SDP. Basic auth is the only
    scheme the platform supports.

    .PARAMETER throttleCorrection
    When set, every REST call sleeps 1 second after returning. Useful for
    APIs that rate-limit aggressively.

    .PARAMETER resolve
    Reserved for future use; currently passed through onto the session
    object for downstream cmdlets to inspect.

    .PARAMETER k2context
    Name of the global session variable. Override only when you need to
    connect to multiple SDPs simultaneously.

    .EXAMPLE
    $creds = Get-Credential
    Connect-SDP -Server 10.10.47.16 -Credentials $creds

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Connect-SDP {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string] $server,
        [parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $credentials,
        [parameter()]
        [switch] $throttleCorrection,
        [parameter()]
        [switch] $resolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    $session = New-Object psobject
    $session | Add-Member -MemberType NoteProperty -Name 'credentials' -Value $credentials
    $session | Add-Member -MemberType NoteProperty -Name 'K2Endpoint' -Value $server
    $session | Add-Member -MemberType NoteProperty -Name 'throttleCorrection' -Value $throttleCorrection
    $session | Add-Member -MemberType NoteProperty -Name 'resolve' -Value $resolve

    Set-Variable -Name $k2context -Value $session -Scope Global

    $results = Invoke-SDPRestCall -endpoint 'system/state' -method GET -k2context $k2context

    return $results
}
