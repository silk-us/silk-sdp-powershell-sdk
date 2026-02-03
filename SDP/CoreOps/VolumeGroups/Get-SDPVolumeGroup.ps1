<#
    .SYNOPSIS
    Retrieves volume group information from the SDP.

    .DESCRIPTION
    Queries for existing volume groups on the Silk Data Pod. Volume groups are containers for volumes that share capacity policies and snapshot schedules.

    .PARAMETER description
    Filter volume groups by description text.

    .PARAMETER id
    The unique identifier of the volume group.

    .PARAMETER name
    The name of the volume group to retrieve.

    .PARAMETER replication_peer_volume_group
    Filter volume groups by replication peer volume group.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolumeGroup
    Retrieves all volume groups from the SDP.

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01"
    Retrieves the volume group named "VG01".

    .EXAMPLE
    Get-SDPVolumeGroup -id 15
    Retrieves the volume group with ID 15.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Get-SDPVolumeGroup {
    param(
        [parameter()]
        [Alias("CapacityState")]
        [string] $capacity_state,
        [parameter()]
        [string] $description,
        [parameter()]
        [int] $id,
        [parameter(Position=1)]
        [string] $name,
        [parameter()]
        [Alias("ReplicationPeerVolumeGroup")]
        [string] $replication_peer_volume_group,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    begin {
        $endpoint = 'volume_groups'
    }
    
    process {

        # special ops

        if ($volumeGroupObject) {
            $id = ConvertFrom-SDPObjectPrefix -Object $volumeGroupObject -getId
            $PSBoundParameters['id'] = $id
            $PSBoundParameters.remove('volumeGroupObject')
        }
        
        # usual routine

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        return $results
    }
    
}