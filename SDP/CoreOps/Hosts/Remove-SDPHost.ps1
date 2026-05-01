<#
    .SYNOPSIS
    Deletes a host from the SDP.

    .DESCRIPTION
    Removes an existing host object from the Silk Data Pod. The host must
    not have any active mappings or identifiers (IQNs, PWWNs, NQNs)
    attached.

    .PARAMETER id
    The unique identifier of the host. Accepts piped input from Get-SDPHost.

    .PARAMETER name
    The name of the host to remove.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Remove-SDPHost -name "WinHost01"

    .EXAMPLE
    Get-SDPHost -name "WinHost01" | Remove-SDPHost

    .EXAMPLE
    Remove-SDPHost -id 45

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPHost {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter(Position=1)]
        [string] $name,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "hosts"
    }

    process {
        if ($name) {
            $id = (Get-SDPHost -name $name -k2context $k2context).id
        }

        Write-Verbose "Removing host with id $id"
        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
        return $results
    }
}
