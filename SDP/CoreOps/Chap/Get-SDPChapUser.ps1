<#
    .SYNOPSIS
    Retrieves CHAP user information from the SDP.

    .DESCRIPTION
    Queries the SDP for existing CHAP host auth profiles. Filter by name
    or id.

    .PARAMETER name
    Filter by CHAP user name. Accepts pipeline input by property name.

    .PARAMETER id
    Filter by CHAP user id.

    .PARAMETER userName
    Filter by underlying CHAP username.

    .PARAMETER doNotResolve
    Skip ref-name resolution on the returned objects. Used by internal
    callers to avoid recursive resolution.

    .PARAMETER k2context
    K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPChapUser

    .EXAMPLE
    Get-SDPChapUser -name ChapUser01

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPChapUser {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $name,
        [parameter()]
        [int] $id,
        [parameter()]
        [int] $userName,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "host_auth_profiles"
    }

    process {

        # Strip internal-only switches before passing to the URI builder.
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        # Query

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPChapUser'

        if ($doNotResolve) {
            return $results
        }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
