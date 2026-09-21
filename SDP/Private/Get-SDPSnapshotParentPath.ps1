<#
    Snapshots, views and view-snapshots all live at /snapshots and only
    differ by what their source points at:

        snapshot       source = /volume_groups/N
        view           source = /snapshots/N  where N is a snapshot
        view-snapshot  source = /snapshots/N  where N is a view

    So to classify a record you need to know the *parent's* source path.
    Given a set of snapshot-sourced records this returns a hashtable of
    id -> source path covering the records and their parents, fetching
    any parents that arent already in the set with one id__in call.
#>

function Get-SDPSnapshotParentPath {
    param(
        [parameter()]
        [array] $snapshots,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    $map = @{}
    if (-not $snapshots) {
        return $map
    }

    foreach ($s in $snapshots) {
        $map[[string]$s.id] = (ConvertFrom-SDPObjectPrefix -Object $s.source).ObjectPath
    }

    $parentIds = foreach ($s in $snapshots) {
        (ConvertFrom-SDPObjectPrefix -Object $s.source).ObjectId
    }
    $missing = @($parentIds | Sort-Object -Unique | Where-Object { -not $map.ContainsKey([string]$_) })

    if ($missing.Count -gt 0) {
        $parents = Invoke-SDPRestCall -endpoint 'snapshots' -method GET -parameterList @{ id = [array]$missing } -context $context
        foreach ($p in $parents) {
            $map[[string]$p.id] = (ConvertFrom-SDPObjectPrefix -Object $p.source).ObjectPath
        }
    }

    return $map
}
