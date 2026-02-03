<#
    .SYNOPSIS
    Assigns a PWWN (Port World Wide Name) to a host.

    .DESCRIPTION
    Associates a Fibre Channel PWWN with a host object on the Silk Data Pod. This enables FC connectivity for the host.

    .PARAMETER hostName
    The name of the host to assign the PWWN to. Accepts piped input from Get-SDPHost.

    .PARAMETER pwwn
    The Port World Wide Name to assign to the host. Format: 16 hexadecimal characters (e.g., 50:06:0B:00:00:C2:62:10).

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Set-SDPHostPwwn -hostName "ESXHost01" -pwwn "50:06:0B:00:00:C2:62:10"
    Assigns a PWWN to the host named "ESXHost01".

    .EXAMPLE
    Get-SDPHost -name "ESXHost01" | Set-SDPHostPwwn -pwwn "50:06:0B:00:00:C2:62:10"
    Assigns a PWWN using piped host input.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Set-SDPHostPwwn {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $pwwn,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'host_fc_ports'
    }

    process{
        ## Special Ops

        $hostid = Get-SDPHost -name $hostname -k2context $k2context
        $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath 'hosts' -ObjectID $hostid.id -nestedObject

        # Build the Object
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "pwwn" -Value $pwwn
        $o | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        
        $body = $o

        ## Make the call
        # $endpointURI = $endpoint + '/' + $hostid.id
        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        return $results
    }
}