<#
    .SYNOPSIS
    Assigns an NQN to a host.

    .EXAMPLE
    Set-SDPHostNqn -hostName Host01 -nqn nqn.2014-08.org.nvmexpress:uuid:0123456789ABCDEF

    .EXAMPLE
    Get-SDPHost -name Host01 | Set-SDPHostNqn -nqn nqn.2014-08.org.nvmexpress:uuid:0123456789ABCDEF

    .DESCRIPTION
    Set's the NQN for any host. Accepts piped input from Get-SDPHost.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPHostNqn {
    [CmdletBinding()]
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $nqn,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'host_nqns'
    }

    process {

        # Special Ops — resolve host name to a nested ref.

        $hostObj = Get-SDPHost -name $hostName -k2context $k2context -doNotResolve
        $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath 'hosts' -ObjectID $hostObj.id -nestedObject

        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "nqn" -Value $nqn
        $body | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath

        # Call

        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context
        return $results
    }
}
