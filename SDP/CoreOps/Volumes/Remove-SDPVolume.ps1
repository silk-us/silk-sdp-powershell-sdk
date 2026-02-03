<#
    .SYNOPSIS
    Deletes a volume from the SDP.

    .DESCRIPTION
    Removes an existing volume from the Silk Data Pod. The volume must not be mapped to any hosts.

    .PARAMETER id
    The unique identifier of the volume to remove. Accepts piped input from Get-SDPVolume.

    .PARAMETER name
    The name of the volume to remove.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Remove-SDPVolume -name "Vol01"
    Removes the volume named "Vol01".

    .EXAMPLE
    Get-SDPVolume -name "Vol01" | Remove-SDPVolume
    Removes a volume using piped input.

    .EXAMPLE
    Remove-SDPVolume -id 123
    Removes the volume with ID 123.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Remove-SDPVolume {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )    

    begin {
        $endpoint = "volumes"
    }

    process {

        # Special Ops

        if ($name) {
            $volname = Get-SDPVolume -name $name -k2context $k2context
            if (!$volname) {
                return "No volume with name $name exists."
            } elseif (($volname | measure-object).count -gt 1) {
                return "Too many replies with $name"
            } else {
                $id = $volname.id
            }
        }

        # Call
        
        $endpointURI = $endpoint + '/' + $id
        Write-Verbose "Removing volume with id $id"
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context

        return $results
    }
}
