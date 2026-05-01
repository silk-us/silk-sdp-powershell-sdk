<#
    .SYNOPSIS
    Deletes a CHAP user from the SDP.

    .DESCRIPTION
    Removes an existing CHAP host auth profile. Accepts either a name or
    an id; when only a name is given it is resolved to an id first.

    .PARAMETER name
    The CHAP user name to remove.

    .PARAMETER id
    The CHAP user id to remove. Accepts pipeline input by property name.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Remove-SDPChapUser -name ChapUser01

    .EXAMPLE
    Get-SDPChapUser -name ChapUser01 | Remove-SDPChapUser

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPChapUser {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [int] $id,
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

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
        return $results
    }
}
