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
    <#
        .SYNOPSIS

        .EXAMPLE 

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
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