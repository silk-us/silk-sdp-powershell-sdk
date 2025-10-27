<#
    .SYNOPSIS
    Connects you to an SDP instance. 

    .DESCRIPTION
    This is the function for establishing a session to an existing SDP.

    .PARAMETER server
    [string] - Management IP or name for the SDP console.

    .PARAMETER credential
    [PSCredential] - A credential object to use to provide authentication to the desired SDP.

    .PARAMETER k2context
    [string] - Specify a context
    
    .EXAMPLE
    $creds = get-credential
    Connect-SDP -Server 10.10.47.16 -Credentials $cred

    This will connect you to an existing SDP. 

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Connect-SDP {
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

    # $K2header = New-SDPAPIHeader -Credential $credentials

    $o = New-Object psobject
    $o | Add-Member -MemberType NoteProperty -Name 'credentials' -Value $credentials
    $o | Add-Member -MemberType NoteProperty -Name 'K2Endpoint' -Value $server
    $o | Add-Member -MemberType NoteProperty -Name 'throttleCorrection' -Value $throttleCorrection
    $o | Add-Member -MemberType NoteProperty -Name 'resolve' -Value $resolve

    Set-Variable -Name $k2context -Value $o -Scope Global

    $results = Invoke-SDPRestCall -endpoint 'system/state' -method GET -k2context $k2context

    return $results
}