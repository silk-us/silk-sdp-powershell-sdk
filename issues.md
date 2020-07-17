## Function re-writes

- SDPHostMapping needs to be expanded to accept volume/volumeGroup/host/hostGroup names. 
    - Actually, need an entire re-write of the host mappings
        - perhaps split into:
            - New-SDPHostMapping 
            - New-SDPHostGroupMapping
    - Perhaps split GET into 4 functions, one for each piped input. 
        - Get-SDPHostMapping
        - Get-SDPHostGroupMapping
        - Get-SDPVolumeMapping
        - Get-SDPVolumeGroupMapping
- Get-SDPVolumeSnapshot also needs to be expanded for the same.

## Function additions

- Remove-SDPReplicationSession
- Remove-SDPReplicationVolume

## Tests

- Validate all replication functions


## Classes

- Start with building classees for:
    - Hosts
    - HostGroups
    - Volumes
    - VolumeGroups

## Errors

- Sanitize every Get-SDP*** call made within any function and try/catch/write-error 