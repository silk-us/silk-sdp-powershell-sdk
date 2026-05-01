<#
    .SYNOPSIS
    Creates a new CHAP user on the SDP.

    .DESCRIPTION
    Submits a CHAP host auth profile. The username/password pair is read
    from the supplied PSCredential object.

    .PARAMETER name
    Friendly name for the CHAP user.

    .PARAMETER chapCredentials
    PSCredential carrying the CHAP username and password.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    New-SDPChapUser -name ChapUser01 -chapCredentials (Get-Credential)

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPChapUser {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $chapCredentials,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "host_auth_profiles"
    }

    process {

        # Special Ops — pull the username/password off the PSCredential.

        $username = $chapCredentials.UserName
        $password = $chapCredentials.GetNetworkCredential().Password

        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name 'name' -Value $name
        $body | Add-Member -MemberType NoteProperty -Name 'username' -Value $username
        $body | Add-Member -MemberType NoteProperty -Name 'password' -Value $password
        $body | Add-Member -MemberType NoteProperty -Name 'type' -Value 'CHAP'

        # Call

        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context
        return $results
    }
}
