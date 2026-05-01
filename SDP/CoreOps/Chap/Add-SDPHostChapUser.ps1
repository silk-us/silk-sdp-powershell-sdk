<#
    .SYNOPSIS
    Assigns a CHAP user to a host.

    .DESCRIPTION
    Attaches an existing CHAP user (host auth profile) to an existing
    host. Accepts piped input from Get-SDPHost.

    .PARAMETER hostName
    The host name to attach the CHAP user to. Accepts pipeline input by
    property name.

    .PARAMETER chapUserName
    The CHAP user name to attach.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Add-SDPHostChapUser -hostName Host01 -chapUserName ChapUser01

    .EXAMPLE
    Get-SDPHost -name Host01 | Add-SDPHostChapUser -chapUserName ChapUser01

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Add-SDPHostChapUser {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $chapUserName,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = 'hosts'
    }

    process {

        # Special Ops — resolve the host and CHAP user.

        $hostObj = Get-SDPHost -name $hostName -k2context $k2context -doNotResolve
        $chapUserObj = Get-SDPChapUser -name $chapUserName -k2context $k2context -doNotResolve

        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "map_auth_profiles_names" -Value $chapUserObj.name

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$($hostObj.id)" -method PATCH -body $body -k2context $k2context
        return $results
    }
}
