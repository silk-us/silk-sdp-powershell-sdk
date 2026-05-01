<#
    .SYNOPSIS
    Removes any existing Host Group.

    .EXAMPLE
    Remove-SDPHostGroup -name HostGroup01

    .EXAMPLE
    Get-SDPHostGroup | where {$_.name -like "LinuxHosts*"} | Remove-SDPHostGroup

    .DESCRIPTION
    Use this function to remove any existing Host Group. This command accepts piped input from a Get-SDPHostGroup query.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPHostGroup {
    [CmdletBinding()]
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
        $endpoint = 'host_groups'
    }

    process {

        # Special Ops — resolve name to id when no id was passed.

        if ($name -and !$id) {
            $hostGroup = Get-SDPHostGroup -name $name -k2context $k2context -doNotResolve
            $id = $hostGroup.id
        }

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
        return $results
    }
}
