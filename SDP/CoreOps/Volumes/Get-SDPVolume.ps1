<#
    SDPVolume — typed wrapper for a Silk SDP volume.

    Lives co-located with Get-SDPVolume so the type, the default rendering
    setup, and the cmdlet that emits instances are all one click apart.

    Three jobs:

      1. Real .NET-backed object (IDE IntelliSense, predictable
         serialization, strongly typed properties).
      2. Operational verbs as instance methods so a script can do
              $vol.Resize(500)  /  $vol.Map('host01')  /  $vol.Delete()
         without rebuilding the cmdlet surface.
      3. Carry a default property set so  Get-SDPVolume | Format-Table
         shows a useful narrow column list by default — but every
         property is still there when you ask for it.

    Default table view (name, id, scsi_sn, sizeInGB, creationTime) is
    registered via Update-TypeData below. Format-List * still shows
    everything; direct property access still sees everything.

    sizeInGB and creationTime are computed in the constructor. The raw
    API values (size, creation_time) are retained on the object too in
    case anything downstream still wants them.
#>

class SDPVolume {

    # --- Properties shown in the default table view ---
    [string]   $name
    [string]   $id
    [string]   $scsi_sn
    [int]      $sizeInGB
    [datetime] $creationTime

    # --- Identity (additional) ---
    [int]      $scsi_suffix
    [string]   $iscsi_tgt_converted_name
    [string]   $description

    # --- Sizing (raw + derived) ---
    [long]     $size
    [long]     $logical_capacity
    [long]     $snapshots_logical_capacity

    # --- Volume group ---
    # Stored as the original nested ref object (e.g. @{ref="/volume_groups/4"})
    # so `| Update-SDPRefObjects` can walk it and attach a
    # `volume_group_name` NoteProperty at runtime. Do not flatten.
    [psobject] $volume_group

    # --- Flags ---
    [bool]     $vmware_support
    [bool]     $is_dedup
    [bool]     $is_new
    [bool]     $marked_for_deletion

    # --- Lifecycle ---
    [int]      $creation_time

    # --- Replication ---
    # Same nested-ref shape as volume_group; preserved for Update-SDPRefObjects.
    [psobject] $replication_peer_volume

    # Hidden — used by instance methods to stay on the same SDP context
    # the object came from.
    hidden [string] $k2context

    SDPVolume() {}

    SDPVolume([psobject] $apiHit, [string] $k2context) {
        $this.id                       = $apiHit.id
        $this.name                     = $apiHit.name
        $this.scsi_sn                  = $apiHit.scsi_sn
        $this.scsi_suffix              = $apiHit.scsi_suffix
        $this.iscsi_tgt_converted_name = $apiHit.iscsi_tgt_converted_name
        $this.description              = $apiHit.description
        $this.size                     = $apiHit.size
        $this.logical_capacity         = $apiHit.logical_capacity
        $this.snapshots_logical_capacity = $apiHit.snapshots_logical_capacity
        $this.vmware_support           = [bool] $apiHit.vmware_support
        $this.is_dedup                 = [bool] $apiHit.is_dedup
        $this.is_new                   = [bool] $apiHit.is_new
        $this.marked_for_deletion      = [bool] $apiHit.marked_for_deletion
        $this.creation_time            = $apiHit.creation_time
        $this.k2context                = $k2context

        # Computed: GB from the API's KB-block size.
        if ($apiHit.size) {
            $this.sizeInGB = [int] ($apiHit.size / 1024 / 1024)
        }

        # Computed: DateTime from the Unix timestamp.
        if ($apiHit.creation_time) {
            $this.creationTime = Convert-SDPTimeStampFrom -timestamp $apiHit.creation_time
        }

        # Refs preserved in their nested-object form so a downstream
        # `| Update-SDPRefObjects` can detect them.
        if ($apiHit.volume_group) {
            $this.volume_group = $apiHit.volume_group
        }
        if ($apiHit.replication_peer_volume) {
            $this.replication_peer_volume = $apiHit.replication_peer_volume
        }
    }

    # ---- Operational methods --------------------------------------------

    [SDPVolume] Resize([int] $newSizeInGB) {
        Set-SDPVolume -id $this.id -sizeInGB $newSizeInGB -k2context $this.k2context | Out-Null
        $this.sizeInGB = $newSizeInGB
        $this.size     = $newSizeInGB * 1024 * 1024
        return $this
    }

    [void] Map([string] $hostName) {
        New-SDPHostMapping -hostName $hostName -volumeName $this.name -k2context $this.k2context | Out-Null
    }

    [void] Unmap([string] $hostName) {
        Get-SDPHostMapping -hostName $hostName -volumeName $this.name -k2context $this.k2context |
            Remove-SDPHostMapping -k2context $this.k2context | Out-Null
    }

    [SDPVolume] Refresh() {
        # Mutate $this in place so callers' existing references stay current.
        # Copy declared properties via assignment; carry over Update-SDPRefObjects
        # NoteProperties (volume_group_name, etc.) via Add-Member -Force.
        $fresh = Get-SDPVolume -id $this.id -k2context $this.k2context
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
        Remove-SDPVolume -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return "$($this.name) ($($this.sizeInGB) GB)"
    }
}

# Default rendering registration. Runs once when this file is dot-sourced
# at module load. -Force lets the file be re-sourced without throwing
# "type already exists."
Update-TypeData -TypeName 'SDPVolume' `
                -DefaultDisplayPropertySet 'name','id','scsi_sn','sizeInGB','creationTime' `
                -Force


<#
    .SYNOPSIS
    Retrieves volume information from the SDP.

    .DESCRIPTION
    Queries for existing volumes on the Silk Data Pod. Can filter by name,
    ID, volume group, or other properties. Returns SDPVolume instances
    that render as a narrow table by default and expose Resize / Map /
    Unmap / Delete methods.

    .PARAMETER description
    Filter volumes by description text.

    .PARAMETER id
    The unique identifier of the volume.

    .PARAMETER name
    The name of the volume to retrieve.

    .PARAMETER vmware_support
    Filter volumes by VMware support flag.

    .PARAMETER volume_group
    Filter volumes by volume group name or ID. Accepts piped input from
    Get-SDPVolumeGroup.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolume
    Retrieves all volumes from the SDP.

    .EXAMPLE
    Get-SDPVolume -name "Vol01"
    Retrieves the volume named "Vol01".

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01" | Get-SDPVolume
    Retrieves all volumes in the volume group "VG01".

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPVolume {
    [CmdletBinding()]
    [OutputType([SDPVolume])]
    param(
        [parameter()]
        [string] $description,
        [parameter()]
        [int] $id,
        [parameter(Position=1)]
        [ValidateLength(0, 42)]
        [string] $name,
        [parameter()]
        [Alias("VmwareSupport")]
        [bool] $vmware_support,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [Alias("VolumeGroup")]
        [string] $volume_group,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "volumes"
    }

    process {

        # Special Ops

        if ($volume_group) {
            Write-Verbose "volume_group specified, parsing SDP object reference"
            $PSBoundParameters.volume_group = ConvertTo-SDPObjectPrefix -ObjectPath volume_groups -ObjectID $volume_group -nestedObject
        }

        # Strip internal-only switches before passing to Invoke-SDPRestCall —
        # they shouldn't end up as URI query parameters.
        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        # Query

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI

        # Emit typed objects so the default view + class methods kick in.

        $instances = foreach ($hit in $results) {
            [SDPVolume]::new($hit, $k2context)
        }

        # Auto-resolve refs unless the caller opted out. Ref resolution
        # adds `_name` NoteProperties (volume_group_name etc.) which the
        # default table view picks up.
        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
