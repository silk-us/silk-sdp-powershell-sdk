<#
    .SYNOPSIS
    Deletes a host from the SDP.

    .DESCRIPTION
    Removes an existing host object from the Silk Data Pod. The host must not have any active mappings or identifiers (IQNs, PWWNs, NQNs) attached.

    .PARAMETER id
    The unique identifier of the host to remove. Accepts piped input from Get-SDPHost.

    .PARAMETER name
    The name of the host to remove.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Remove-SDPHost -name "WinHost01"
    Removes the host named "WinHost01".

    .EXAMPLE
    Get-SDPHost -name "WinHost01" | Remove-SDPHost
    Removes a host using piped input.

    .EXAMPLE
    Remove-SDPHost -id 45
    Removes the host with ID 45.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Remove-SDPHost {
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
            $id = (Get-SDPHost -name $name).id
        }
        Write-Verbose "Removing volume with id $id"
        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
        return $results.hits
    }
}

