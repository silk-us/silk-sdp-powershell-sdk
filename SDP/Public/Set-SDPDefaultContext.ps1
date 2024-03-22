function Set-SDPDefaultContext {
    param(
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Connect to a Kaminario K2 appliance. 

        .DESCRIPTION
        Connect to a Kaminario K2 appliance. 

        .PARAMETER server
        The SDP management IP or DNS name. 

        .PARAMETER credentials
        A standard PowerShell credential object (System.Management.Automation.PSCredential)

        .INPUTS
        Connect-SDP does not accept piped inputs. 

        .OUTPUTS
        Returns the SDP 'system/state' endpoint information. 

        .EXAMPLE 
        Connect-SDP -credentials $creds -server 10.10.1.20
        This connects ad-hoc to a Kaminario appliace using a conventional powershell credential object under a default global context.

        .EXAMPLE
        Connect-SDP -credentials $creds -server 172.16.2.13 -k2context TestDev
        This connects ad-hoc to a Kaminario appliace using a conventional powershell credential object under a specific context,
        for later issuing commands to a specific K2 appliance  (Get-SDPVolumeGroup -k2context TestDev)
    
    #>

    # $K2header = New-SDPAPIHeader -Credential $credentials

    $contextVar = Get-Variable -Name $k2context

    $o = New-Object psobject
    $o | Add-Member -MemberType NoteProperty -Name 'credentials' -Value $contextVar.Value.credentials
    $o | Add-Member -MemberType NoteProperty -Name 'K2Endpoint' -Value $contextVar.Value.K2Endpoint

    Set-Variable -Name 'k2rfconnection' -Value $o -Scope Global

    $results = Invoke-SDPRestCall -endpoint 'system/state' -method GET -k2context 'k2rfconnection'

    return $results
}