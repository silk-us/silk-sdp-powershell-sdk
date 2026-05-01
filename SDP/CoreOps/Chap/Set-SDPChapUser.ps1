<#
    .SYNOPSIS
    Updates the credentials of an existing CHAP user.

    .DESCRIPTION
    Replaces the CHAP username and password on an existing host auth
    profile. The id can be passed directly or resolved by name.

    .PARAMETER name
    The CHAP user name. Used to look up the id when one isn't provided.

    .PARAMETER id
    The CHAP user id. Accepts pipeline input by property name.

    .PARAMETER chapCredentials
    PSCredential carrying the new CHAP username and password.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Set-SDPChapUser -name ChapUser01 -chapCredentials (Get-Credential)

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPChapUser {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [int] $id,
        [parameter()]
        [System.Management.Automation.PSCredential] $chapCredentials,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "host_auth_profiles"
    }

    process {

        # Special Ops — resolve name -> id when no id was given.

        if ($name -and -not $id) {
            $id = (Get-SDPChapUser -name $name -k2context $k2context -doNotResolve).id
        }

        $username = $chapCredentials.UserName
        $password = $chapCredentials.GetNetworkCredential().Password

        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name 'new_username' -Value $username
        $body | Add-Member -MemberType NoteProperty -Name 'new_password' -Value $password

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method PATCH -body $body -k2context $k2context
        return $results
    }
}
