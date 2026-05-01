<#
    .SYNOPSIS
    Creates a new volume group snapshot or a snapshot of a view.

    .DESCRIPTION
    All snapshots on the SDP live at the same /snapshots endpoint and
    differ only by what the `source` ref points at. This cmdlet covers
    both common cases via parameter sets:

      VolumeGroup (default) — `source` = /volume_groups/X. The classic
        "snapshot of a volume group" (regular snapshot).

      View — `source` = /snapshots/X where X is itself a view. Produces
        a "snapshot of a view" (also called a view-snapshot in some
        docs).

    The standalone `New-SDPVolumeGroupViewSnapshot` cmdlet is gone in
    v2 — use the View parameter set here instead.

    For replication snapshots, supply `-replicationSession`. In that
    case `-retentionPolicyName` is not required (the API doesn't accept
    a retention policy on replication snapshots).

    .PARAMETER name
    Short name for the new snapshot. Becomes the `short_name` field on
    the API record. The full `name` returned by the API will be
    `{sourceName}:{name}`.

    .PARAMETER volumeGroupName
    (VolumeGroup set) Name of the volume group to snapshot.

    .PARAMETER viewName
    (View set) Name of the view to snapshot.

    .PARAMETER retentionPolicyName
    Retention policy to apply to the new snapshot. Required unless
    `-replicationSession` is supplied.

    .PARAMETER deletable
    Marks the snapshot as auto-deleteable.

    .PARAMETER exposable
    Marks the snapshot as exposable (i.e. mappable to a host like a
    view). For a writable view of a snapshot, see New-SDPVolumeGroupView.

    .PARAMETER replicationSession
    Optional replication session to attach this snapshot to. When set,
    the SDP treats this as a replication snapshot and `retentionPolicyName`
    is not required.

    .PARAMETER k2context
    K2 context name. Defaults to 'k2rfconnection'.

    .EXAMPLE
    New-SDPVolumeGroupSnapshot -name test-snap -volumeGroupName test-vg -retentionPolicyName Backup

    .EXAMPLE
    New-SDPVolumeGroupSnapshot -name vs1 -viewName test-view -retentionPolicyName Backup

    .EXAMPLE
    New-SDPVolumeGroupSnapshot -name rep-snap -volumeGroupName test-vg -replicationSession session01

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPVolumeGroupSnapshot {
    [CmdletBinding(DefaultParameterSetName = 'VolumeGroup')]
    param(
        [parameter(Mandatory)]
        [string] $name,

        [parameter(Mandatory, ParameterSetName = 'VolumeGroup', ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $volumeGroupName,

        [parameter(Mandatory, ParameterSetName = 'View', ValueFromPipelineByPropertyName)]
        [string] $viewName,

        [parameter()]
        [string] $retentionPolicyName,

        [parameter()]
        [switch] $deletable,

        [parameter()]
        [switch] $exposable,

        [parameter()]
        [string] $replicationSession,

        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'snapshots'
    }

    process {

        # retention_policy is mandatory unless this is a replication snapshot.
        if (!$retentionPolicyName -and !$replicationSession) {
            Write-Error "Specify either -retentionPolicyName or -replicationSession."
            return
        }

        # Resolve the source ref based on which parameter set was chosen.
        $isViewSnap = $PSCmdlet.ParameterSetName -eq 'View'
        if ($isViewSnap) {
            $sourceObj = Get-SDPVolumeGroupView -name $viewName -k2context $k2context
            if (!$sourceObj) {
                Write-Error "No view named $viewName exists."
                return
            }
            $sourceRef       = ConvertTo-SDPObjectPrefix -ObjectPath 'snapshots' -ObjectID $sourceObj.id -nestedObject
            $expectedFullName = "${viewName}:${name}"
        } else {
            $sourceObj = Get-SDPVolumeGroup -name $volumeGroupName -k2context $k2context -doNotResolve
            if (!$sourceObj) {
                Write-Error "No volume group named $volumeGroupName exists."
                return
            }
            $sourceRef       = ConvertTo-SDPObjectPrefix -ObjectPath 'volume_groups' -ObjectID $sourceObj.id -nestedObject
            $expectedFullName = "${volumeGroupName}:${name}"
        }

        # Build the request body.

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name 'short_name' -Value $name
        $body | Add-Member -MemberType NoteProperty -Name 'source'     -Value $sourceRef

        if ($retentionPolicyName) {
            $rp = Get-SDPRetentionPolicy -name $retentionPolicyName -k2context $k2context -doNotResolve
            if (!$rp) {
                Write-Error "No retention policy named $retentionPolicyName exists."
                return
            }
            $rpRef = ConvertTo-SDPObjectPrefix -ObjectPath 'retention_policies' -ObjectID $rp.id -nestedObject
            $body | Add-Member -MemberType NoteProperty -Name 'retention_policy' -Value $rpRef
        }

        if ($deletable) {
            $body | Add-Member -MemberType NoteProperty -Name 'is_auto_deleteable' -Value $true
        }
        if ($exposable) {
            $body | Add-Member -MemberType NoteProperty -Name 'is_exposable' -Value $true
        }

        if ($replicationSession) {
            $session = Get-SDPReplicationSessions -name $replicationSession -k2context $k2context
            if (!$session) {
                Write-Error "No replication session named $replicationSession exists."
                return
            }
            $sessionRef = ConvertTo-SDPObjectPrefix -ObjectPath 'replication/sessions' -ObjectID $session.id -nestedObject
            $body | Add-Member -MemberType NoteProperty -Name 'replication_session' -Value $sessionRef
        }

        # POST returns nothing on success — submit and then poll the GET
        # until the new snapshot appears.

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $expectedFullName -Get {
            if ($isViewSnap) {
                Get-SDPVolumeGroupSnapshot -name $expectedFullName -asViewSnapshot -k2context $k2context -doNotResolve
            } else {
                Get-SDPVolumeGroupSnapshot -name $expectedFullName -k2context $k2context -doNotResolve
            }
        }

        return $results
    }
}
