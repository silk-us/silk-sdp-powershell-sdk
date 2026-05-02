<#
    SDPVolumeGroupView — typed wrapper for a Silk SDP view (snapshot
    record with `is_exposable=true` whose source is a regular snapshot).

    `source`, `volume_group`, `retention_policy`, and `replication_session`
    are ref-shaped; Update-SDPRefObjects attaches `*_name`
    NoteProperties at runtime. `creationTime` is a computed [datetime]
    derived from the raw `creation_time` int.
#>

class SDPVolumeGroupView {

    # --- Identity / properties shown in the default table view ---
    [string]   $name
    [string]   $id
    [string]   $short_name

    # --- Lifecycle ---
    [datetime] $creationTime
    [int]      $creation_time
    [int]      $data_creation_time
    [int]      $last_exposed_time
    [int]      $num_of_clones
    [string]   $triggered_by

    # --- Identity (additional) ---
    [string]   $description
    [string]   $iscsi_tgt_converted_name
    [string]   $wwn
    [int]      $generation_number

    # --- Sizing ---
    [long]     $volsnaps_provisioned_capacity

    # --- Flags ---
    [bool]     $is_application_consistent
    [bool]     $is_auto_deleteable
    [bool]     $is_deleted
    [bool]     $is_exist_on_peer
    [bool]     $is_exposable
    [bool]     $is_external
    [bool]     $is_locked_by_replication
    [bool]     $is_originating_from_peer

    # --- Refs (kept nested for Update-SDPRefObjects). ---
    [psobject] $source
    [psobject] $volume_group
    [psobject] $retention_policy
    [psobject] $replication_session

    # Hidden context
    hidden [string] $k2context

    SDPVolumeGroupView() {}

    SDPVolumeGroupView([psobject] $apiHit, [string] $k2context) {
        $this.id                            = $apiHit.id
        $this.name                          = $apiHit.name
        $this.short_name                    = $apiHit.short_name
        $this.description                   = $apiHit.description
        $this.iscsi_tgt_converted_name      = $apiHit.iscsi_tgt_converted_name
        $this.wwn                           = $apiHit.wwn
        $this.generation_number             = $apiHit.generation_number
        $this.creation_time                 = $apiHit.creation_time
        $this.data_creation_time            = $apiHit.data_creation_time
        $this.last_exposed_time             = $apiHit.last_exposed_time
        $this.num_of_clones                 = $apiHit.num_of_clones
        $this.triggered_by                  = $apiHit.triggered_by
        $this.volsnaps_provisioned_capacity = $apiHit.volsnaps_provisioned_capacity
        $this.is_application_consistent     = [bool] $apiHit.is_application_consistent
        $this.is_auto_deleteable            = [bool] $apiHit.is_auto_deleteable
        $this.is_deleted                    = [bool] $apiHit.is_deleted
        $this.is_exist_on_peer              = [bool] $apiHit.is_exist_on_peer
        $this.is_exposable                  = [bool] $apiHit.is_exposable
        $this.is_external                   = [bool] $apiHit.is_external
        $this.is_locked_by_replication      = [bool] $apiHit.is_locked_by_replication
        $this.is_originating_from_peer      = [bool] $apiHit.is_originating_from_peer
        $this.k2context                     = $k2context

        if ($apiHit.creation_time) {
            $this.creationTime = Convert-SDPTimeStampFrom -timestamp ([int] $apiHit.creation_time)
        }

        if ($apiHit.source)              { $this.source              = $apiHit.source }
        if ($apiHit.volume_group)        { $this.volume_group        = $apiHit.volume_group }
        if ($apiHit.retention_policy)    { $this.retention_policy    = $apiHit.retention_policy }
        if ($apiHit.replication_session) { $this.replication_session = $apiHit.replication_session }
    }

    # ---- Operational methods --------------------------------------------

    [SDPVolumeGroupView] Refresh() {
        return [SDPVolumeGroupView]::new(
            (Get-SDPVolumeGroupView -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [void] Map([string] $hostName) {
        New-SDPHostMapping -hostName $hostName -viewName $this.name -k2context $this.k2context | Out-Null
    }

    [void] Delete() {
        Remove-SDPVolumeGroupView -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return $this.name
    }
}

Update-TypeData -TypeName 'SDPVolumeGroupView' `
                -DefaultDisplayPropertySet 'name','id','source_name','retention_policy_name','creationTime','is_exposable' `
                -Force


<#
    .SYNOPSIS
    Retrieves volume group views from the SDP.

    .DESCRIPTION
    A view is a snapshot record with `is_exposable=true` whose source is
    a regular snapshot. Views can be mapped to hosts as if they were
    volume groups.

    This function returns only views — it filters out regular snapshots
    (whose source is a volume group) and view-snapshots (whose source is
    itself a view).

    .PARAMETER name
    Filter by full view name (the `vg:short_name` form).

    .PARAMETER short_name
    Filter by short name only.

    .PARAMETER id
    Unique identifier of the view.

    .PARAMETER volumeGroupName
    Filter by parent volume group name. Accepts piped input from
    Get-SDPVolumeGroup.

    .PARAMETER doNotResolve
    Skip the auto-pipe through Update-SDPRefObjects.

    .PARAMETER k2context
    K2 context name. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolumeGroupView

    .EXAMPLE
    Get-SDPVolumeGroupView -name "test-vg:test-view"

    .EXAMPLE
    Get-SDPVolumeGroup -name "test-vg" | Get-SDPVolumeGroupView

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPVolumeGroupView {
    [CmdletBinding()]
    [OutputType([SDPVolumeGroupView])]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias("pipeName")]
        [string] $volumeGroupName,
        [parameter()]
        [string] $description,
        [parameter()]
        [Alias("GenerationNumber")]
        [int] $generation_number,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IscsiTgtConvertedName")]
        [string] $iscsi_tgt_converted_name,
        [parameter()]
        [Alias("IsApplicationConsistent")]
        [bool] $is_application_consistent,
        [parameter()]
        [Alias("IsAutoDeleteable")]
        [bool] $is_auto_deleteable,
        [parameter()]
        [Alias("IsDeleted")]
        [bool] $is_deleted,
        [parameter()]
        [Alias("IsExistOnPeer")]
        [bool] $is_exist_on_peer,
        [parameter()]
        [Alias("IsExposable")]
        [bool] $is_exposable,
        [parameter()]
        [Alias("IsExternal")]
        [bool] $is_external,
        [parameter()]
        [Alias("IsOriginatingFromPeer")]
        [bool] $is_originating_from_peer,
        [parameter()]
        [Alias("LastExposedTime")]
        [string] $last_exposed_time,
        [parameter()]
        [ValidateLength(0, 42)]
        [string] $name,
        [parameter()]
        [Alias("ReplicationSession")]
        [string] $replication_session,
        [parameter()]
        [Alias("RetentionPolicy")]
        [string] $retention_policy,
        [parameter()]
        [Alias("ShortName")]
        [string] $short_name,
        [parameter()]
        [Alias("TriggeredBy")]
        [string] $triggered_by,
        [parameter()]
        [Alias("VolsnapsProvisionedCapacity")]
        [int] $volsnaps_provisioned_capacity,
        [parameter()]
        [Alias("VolumeGroup")]
        [string] $volume_group,
        [parameter()]
        [string] $wwn,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "snapshots"
    }

    process {

        # Special Ops — translate volumeGroupName to a volume_group ref.

        if ($volumeGroupName) {
            $vg = Get-SDPVolumeGroup -name $volumeGroupName -k2context $k2context -doNotResolve
            $volumeGroupPath = ConvertTo-SDPObjectPrefix -ObjectID $vg.id -ObjectPath 'volume_groups' -nestedObject
            $PSBoundParameters.remove('volumeGroupName') | Out-Null
            $PSBoundParameters.volume_group = $volumeGroupPath
        }

        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI

        # Views: source is a /snapshots/ ref AND that source itself has
        # source = /volume_groups/ (i.e. it's a regular snapshot, not a view).
        $snapSourced = foreach ($r in $results) {
            $ref = ConvertFrom-SDPObjectPrefix -Object $r.source
            if ($ref.ObjectPath -eq 'snapshots') { $r }
        }
        $views = foreach ($r in $snapSourced) {
            $ref = ConvertFrom-SDPObjectPrefix -Object $r.source
            if ($snapSourced.id -notcontains $ref.ObjectId) { $r }
        }

        $instances = foreach ($hit in $views) {
            [SDPVolumeGroupView]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
