<#
    .SYNOPSIS
    Removes a CHAP user from a host.

    .DESCRIPTION
    Clears the CHAP user assignment on an existing host. Accepts piped
    input from Get-SDPHost.

    .PARAMETER hostName
    The host name to clear the CHAP user from. Accepts pipeline input by
    property name.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Remove-SDPHostChapUser -hostName Host01

    .EXAMPLE
    Get-SDPHost -name Host01 | Remove-SDPHostChapUser

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPHostChapUser {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = 'hosts'
    }

    process {

        # Special Ops — resolve the host.

        $hostObj = Get-SDPHost -name $hostName -k2context $k2context -doNotResolve

        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "map_auth_profiles_names" -Value $null

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$($hostObj.id)" -method PATCH -body $body -k2context $k2context
        return $results
    }
}
