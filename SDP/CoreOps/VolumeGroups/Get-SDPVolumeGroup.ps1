<#
    SDPVolumeGroup — typed wrapper for a Silk SDP volume group.

    Lives co-located with Get-SDPVolumeGroup. Defined now so it's available
    to callers that want to construct volume groups from raw API hits;
    Get-SDPVolumeGroup itself still returns raw objects until you flip the
    emit (one-line change at the bottom of this file).
#>

class SDPVolumeGroup {

    # --- Properties shown in the default table view ---
    [string]   $name
    [string]   $id
    [int]      $quotaInGB
    [int]      $volumes_count
    [int]      $snapshots_count
    [string]   $capacity_state

    # --- Identity (additional) ---
    [string]   $description
    [string]   $iscsi_tgt_converted_name
    [bool]     $is_default

    # --- Sizing ---
    [long]     $quota
    [double]   $logical_capacity
    [long]     $volumes_logical_capacity
    [long]     $volumes_provisioned_capacity
    [long]     $snapshots_logical_capacity
    [string]   $snapshots_overhead_state

    # --- Counts ---
    [int]      $views_count
    [int]      $mapped_hosts_count

    # --- Flags ---
    [bool]     $is_dedup

    # --- Lifecycle ---
    [datetime] $creationTime
    [double]   $creation_time
    [int]      $last_snapshot_creation_time

    # --- Refs (kept as nested objects so | Update-SDPRefObjects works) ---
    [psobject] $capacity_policy
    [psobject] $last_restored_from
    [psobject] $replication_session
    [psobject] $replication_peer_volume_group
    [psobject] $replication_rpo_history

    # Hidden context
    hidden [string] $k2context

    SDPVolumeGroup() {}

    SDPVolumeGroup([psobject] $apiHit, [string] $k2context) {
        $this.id                            = $apiHit.id
        $this.name                          = $apiHit.name
        $this.description                   = $apiHit.description
        $this.iscsi_tgt_converted_name      = $apiHit.iscsi_tgt_converted_name
        $this.is_default                    = [bool] $apiHit.is_default
        $this.quota                         = $apiHit.quota
        $this.logical_capacity              = $apiHit.logical_capacity
        $this.volumes_logical_capacity      = $apiHit.volumes_logical_capacity
        $this.volumes_provisioned_capacity  = $apiHit.volumes_provisioned_capacity
        $this.snapshots_logical_capacity    = $apiHit.snapshots_logical_capacity
        $this.snapshots_overhead_state      = $apiHit.snapshots_overhead_state
        $this.capacity_state                = $apiHit.capacity_state
        $this.volumes_count                 = $apiHit.volumes_count
        $this.snapshots_count               = $apiHit.snapshots_count
        $this.views_count                   = $apiHit.views_count
        $this.mapped_hosts_count            = $apiHit.mapped_hosts_count
        $this.is_dedup                      = [bool] $apiHit.is_dedup
        $this.creation_time                 = $apiHit.creation_time
        $this.last_snapshot_creation_time   = $apiHit.last_snapshot_creation_time
        $this.k2context                     = $k2context

        # Computed: GB from KB-block quota.
        if ($apiHit.quota) {
            $this.quotaInGB = [int] ($apiHit.quota / 1024 / 1024)
        }

        # Computed: DateTime from Unix timestamp.
        if ($apiHit.creation_time) {
            $this.creationTime = Convert-SDPTimeStampFrom -timestamp ([int] $apiHit.creation_time)
        }

        # Refs preserved verbatim for Update-SDPRefObjects.
        if ($apiHit.capacity_policy)               { $this.capacity_policy               = $apiHit.capacity_policy }
        if ($apiHit.last_restored_from)            { $this.last_restored_from            = $apiHit.last_restored_from }
        if ($apiHit.replication_session)           { $this.replication_session           = $apiHit.replication_session }
        if ($apiHit.replication_peer_volume_group) { $this.replication_peer_volume_group = $apiHit.replication_peer_volume_group }
        if ($apiHit.replication_rpo_history)       { $this.replication_rpo_history       = $apiHit.replication_rpo_history }
    }

    # ---- Operational methods --------------------------------------------

    [void] AddVolume([string] $volumeName, [int] $sizeInGB) {
        New-SDPVolume -name $volumeName -sizeInGB $sizeInGB -VolumeGroupName $this.name -k2context $this.k2context | Out-Null
    }

    [SDPVolumeGroup] SetQuota([int] $newQuotaInGB) {
        Set-SDPVolumeGroup -id $this.id -quotaInGB $newQuotaInGB -k2context $this.k2context | Out-Null
        return $this.Refresh()
    }

    [SDPVolumeGroup] Refresh() {
        # Mutate $this in place so callers' existing references stay current.
        $fresh = Get-SDPVolumeGroup -id $this.id -k2context $this.k2context
        foreach ($p in $fresh.PSObject.Properties) {
            if ($this.PSObject.Properties[$p.Name]) {
                $this.($p.Name) = $p.Value
            } else {
                Add-Member -InputObject $this -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force
            }
        }
        return $this
    }

    [void] Delete() {
        Remove-SDPVolumeGroup -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return "$($this.name) [$($this.volumes_count) volumes]"
    }
}

Update-TypeData -TypeName 'SDPVolumeGroup' `
                -DefaultDisplayPropertySet 'name','id','quotaInGB','volumes_count','snapshots_count','capacity_state' `
                -Force


<#
    .SYNOPSIS
    Retrieves volume group information from the SDP.

    .DESCRIPTION
    Queries for existing volume groups on the Silk Data Pod. Volume groups
    are containers for volumes that share capacity policies and snapshot
    schedules.

    .PARAMETER description
    Filter volume groups by description text.

    .PARAMETER id
    The unique identifier of the volume group.

    .PARAMETER name
    The name of the volume group to retrieve.

    .PARAMETER capacity_state
    Filter by capacity state.

    .PARAMETER replication_peer_volume_group
    Filter volume groups by replication peer volume group.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolumeGroup

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01"

    .EXAMPLE
    Get-SDPVolumeGroup -id 15

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPVolumeGroup {
    [CmdletBinding()]
    param(
        [parameter()]
        [Alias("CapacityState")]
        [string] $capacity_state,
        [parameter()]
        [string] $description,
        [parameter()]
        [int] $id,
        [parameter(Position=1)]
        [ValidateLength(0, 42)]
        [string] $name,
        [parameter()]
        [Alias("ReplicationPeerVolumeGroup")]
        [string] $replication_peer_volume_group,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'volume_groups'
    }

    process {
        $PSBoundParameters.Remove('doNotResolve') | Out-Null
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI

        $instances = foreach ($hit in $results) {
            [SDPVolumeGroup]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
