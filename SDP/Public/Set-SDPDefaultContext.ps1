function Set-SDPDefaultContext {
    param(
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    # $K2header = New-SDPAPIHeader -Credential $credentials

    $contextVar = Get-Variable -Name $k2context

    $o = New-Object psobject
    $o | Add-Member -MemberType NoteProperty -Name 'credentials' -Value $contextVar.Value.credentials
    $o | Add-Member -MemberType NoteProperty -Name 'K2Endpoint' -Value $contextVar.Value.K2Endpoint

    Set-Variable -Name 'k2rfconnection' -Value $o -Scope Global

    $results = Invoke-SDPRestCall -endpoint 'system/state' -method GET -k2context 'k2rfconnection'

    return $results
}