<#
    SDPVolSnap — typed wrapper for a Silk SDP volsnap. The /volsnaps
    endpoint represents the per-volume slice of a volume-group snapshot
    (and is also what the deprecated Get-SDPVolumeView emits).

    `snapshot` and `source` are ref-shaped; Update-SDPRefObjects attaches
    `snapshot_name` and `source_name` as NoteProperties at runtime.
    `creationTime` is a computed [datetime] from the raw `creation_time`
    int.
#>

class SDPVolSnap {

    # --- Identity ---
    [string]   $id
    [string]   $name
    [string]   $short_name
    [string]   $iscsi_tgt_converted_name

    # --- SCSI ---
    [string]   $scsi_sn
    [int]      $scsi_suffix

    # --- Lifecycle ---
    [datetime] $creationTime
    [double]   $creation_time

    # --- Flags ---
    [bool]     $is_deleted
    [bool]     $is_exposable

    # --- Refs preserved for Update-SDPRefObjects to walk. ---
    [psobject] $snapshot
    [psobject] $source

    # Hidden context
    hidden [string] $k2context

    SDPVolSnap() {}

    SDPVolSnap([psobject] $apiHit, [string] $k2context) {
        $this.id                       = $apiHit.id
        $this.name                     = $apiHit.name
        $this.short_name               = $apiHit.short_name
        $this.iscsi_tgt_converted_name = $apiHit.iscsi_tgt_converted_name
        $this.scsi_sn                  = $apiHit.scsi_sn
        $this.scsi_suffix              = $apiHit.scsi_suffix
        $this.creation_time            = $apiHit.creation_time
        $this.is_deleted               = [bool] $apiHit.is_deleted
        $this.is_exposable             = [bool] $apiHit.is_exposable
        $this.k2context                = $k2context

        if ($apiHit.creation_time) {
            $this.creationTime = Convert-SDPTimeStampFrom -timestamp ([int] $apiHit.creation_time)
        }

        if ($apiHit.snapshot) { $this.snapshot = $apiHit.snapshot }
        if ($apiHit.source)   { $this.source   = $apiHit.source }
    }

    # ---- Operational methods --------------------------------------------

    [SDPVolSnap] Refresh() {
        return [SDPVolSnap]::new(
            (Get-SDPVolSnap -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [string] ToString() {
        return $this.name
    }
}


<#
    .SYNOPSIS
    Retrieves volume snapshot (volsnap) records from the SDP.

    .DESCRIPTION
    A volsnap is the per-volume slice of a volume-group snapshot —
    represents the relationship between a volume and the snapshot that
    captured it. Filter by source snapshot id, by volsnap id, or fetch
    all.

    .PARAMETER sourceId
    Filter by the source snapshot ID.

    .PARAMETER id
    Unique identifier of the volsnap.

    .PARAMETER name
    Filter by full volsnap name (vg:snap:vol).

    .PARAMETER doNotResolve
    Skip the auto-pipe through Update-SDPRefObjects.

    .PARAMETER k2context
    K2 context name. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolSnap

    .EXAMPLE
    Get-SDPVolSnap -sourceId 123

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPVolSnap {
    [CmdletBinding()]
    [OutputType([SDPVolSnap])]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $sourceId,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "volsnaps"
    }

    process {

        # Query
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -k2context $k2context

        # Special Ops — client-side filter by source snapshot.
        if ($sourceId) {
            $sourceObject = ConvertTo-SDPObjectPrefix -ObjectID $sourceId -ObjectPath "snapshots" -compact
            $results = $results | Where-Object { $_.snapshot -match $sourceObject }
        }

        $instances = foreach ($hit in $results) {
            [SDPVolSnap]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
