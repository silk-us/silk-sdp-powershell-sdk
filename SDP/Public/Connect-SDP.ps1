function Connect-SDP {
    param(
        [parameter(Mandatory)]
        [string] $server,
        [parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $credentials,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Connect to a Kaminario K2 appliance. 

        .EXAMPLE 
        Connect-SDP -credentials $creds -server 10.10.1.20

        This connects ad-hoc to a Kaminario appliace using a conventional powershell credential object under a default global context.

        .EXAMPLE
        Connect-SDP -credentials $creds -server 172.16.2.13 -k2context TestDev
        
        This connects ad-hoc to a Kaminario appliace using a conventional powershell credential object under a specific context,
        for later issuing commands to a specific K2 appliance  (Get-SDPVolumeGroup -k2context TestDev)
                
        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/
    
    #>

    # $K2header = New-SDPAPIHeader -Credential $credentials

    $o = New-Object psobject
    $o | Add-Member -MemberType NoteProperty -Name 'credentials' -Value $credentials
    $o | Add-Member -MemberType NoteProperty -Name 'K2Endpoint' -Value $server
    # $o | Add-Member -MemberType NoteProperty -Name 'K2header' -Value $K2header

    Set-Variable -Name $k2context -Value $o -Scope Global
    # return $Global:k2rfconnection

    $results = Invoke-SDPRestCall -endpoint 'system/state' -method GET -k2context $k2context

    return $results
}
