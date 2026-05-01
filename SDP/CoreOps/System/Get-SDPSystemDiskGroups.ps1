<#
    .SYNOPSIS
    Retrieves disk-group state from the SDP.

    .DESCRIPTION
    Queries the `system/disk_groups` endpoint. Filter by name, id, RAID
    level, rebuild progress, etc.

    .EXAMPLE
    Get-SDPSystemDiskGroups

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPSystemDiskGroups {
    [CmdletBinding()]
    param(
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IsExpansionInProgress")]
        [bool] $is_expansion_in_progress,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("RaidLevel")]
        [string] $raid_level,
        [parameter()]
        [Alias("RebuildProgressPercentage")]
        [int] $rebuild_progress_percentage,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "system/disk_groups"
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context |
            Add-SDPTypeName -TypeName 'SDPSystemDiskGroup'

        if ($doNotResolve) { return $results }
        return ($results | Update-SDPRefObjects -k2context $k2context)
    }
}
