<#
    .SYNOPSIS
    Creates a new volume group view (writable, exposable copy of a
    snapshot) on the SDP.

    .DESCRIPTION
    A view is a snapshot record with `is_exposable=true` whose source is
    an existing snapshot. Once created, a view can be mapped to a host
    via New-SDPHostMapping like a volume group.

    `-snapshotName` accepts either:

      * The full SDP name with the `vg:short_name` form
        (e.g. `test-vg:test-snap`).
      * The short name only (e.g. `test-snap`). The cmdlet looks the
        snapshot up by `short_name` in that case. If multiple snapshots
        share the short name across different volume groups you'll get
        an error asking you to disambiguate with the full name.

    .PARAMETER name
    Short name for the new view.

    .PARAMETER snapshotName
    The snapshot to base the view on. Either the full name (with `:`)
    or the short name.

    .PARAMETER retentionPolicyName
    Retention policy to apply to the new view.

    .PARAMETER k2context
    K2 context name. Defaults to 'k2rfconnection'.

    .EXAMPLE
    New-SDPVolumeGroupView -name test-view -snapshotName test-snap -retentionPolicyName Backup

    .EXAMPLE
    New-SDPVolumeGroupView -name test-view -snapshotName test-vg:test-snap -retentionPolicyName Backup

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPVolumeGroupView {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ValidateLength(0, 42)]
        [string] $name,
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $snapshotName,
        [parameter(Mandatory)]
        [string] $retentionPolicyName,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'snapshots'
    }

    process {

        # Special Ops — resolve the snapshot ref.
        # Full name (vg:short_name) → look up by name. Otherwise short_name.

        if ($snapshotName -match ':') {
            $snapshot = Get-SDPVolumeGroupSnapshot -name $snapshotName -k2context $k2context -doNotResolve
        } else {
            $snapshot = Get-SDPVolumeGroupSnapshot -short_name $snapshotName -k2context $k2context -doNotResolve
        }

        if (!$snapshot) {
            Write-Error "No snapshot found matching $snapshotName."
            return
        }
        if (($snapshot | Measure-Object).Count -gt 1) {
            Write-Error "Multiple snapshots match short_name '$snapshotName'. Use the full vg:short_name to disambiguate."
            return
        }

        $snapshotRef = ConvertTo-SDPObjectPrefix -ObjectPath 'snapshots' -ObjectID $snapshot.id -nestedObject

        # Resolve retention policy ref.

        $rp = Get-SDPRetentionPolicy -name $retentionPolicyName -k2context $k2context -doNotResolve
        if (!$rp) {
            Write-Error "No retention policy named $retentionPolicyName exists."
            return
        }
        $rpRef = ConvertTo-SDPObjectPrefix -ObjectPath 'retention_policies' -ObjectID $rp.id -nestedObject

        # Build the request body.

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name 'short_name'         -Value $name
        $body | Add-Member -MemberType NoteProperty -Name 'source'             -Value $snapshotRef
        $body | Add-Member -MemberType NoteProperty -Name 'retention_policy'   -Value $rpRef
        $body | Add-Member -MemberType NoteProperty -Name 'is_auto_deleteable' -Value $true
        $body | Add-Member -MemberType NoteProperty -Name 'is_exposable'       -Value $true

        # Compute the expected full name for the poll. The new view's full
        # name follows the source snapshot's full name pattern: the source
        # snapshot's name is `vg:short_name`, and the view inherits that
        # prefix → `vg:viewName`. Pull the prefix off the source.
        $sourcePrefix = if ($snapshot.name -match ':') { $snapshot.name.Split(':')[0] } else { $snapshot.name }
        $expectedFullName = "${sourcePrefix}:${name}"

        # POST returns nothing on success — submit and poll.

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $expectedFullName -Get {
            Get-SDPVolumeGroupView -name $expectedFullName -k2context $k2context
        }

        return $results
    }
}
