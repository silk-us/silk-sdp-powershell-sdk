<#
.\Test\Test-SDPCrud.ps1 -server 10.0.0.1 -credential (Get-Credential)
.\Test\Test-SDPCrud.ps1                        # reuse an existing Connect-SDP session
.\Test\Test-SDPCrud.ps1 -context k2rfconnection
#>

[CmdletBinding()]
param(
    [parameter()]
    [string] $server,
    [parameter()]
    [pscredential] $credential,
    [parameter()]
    [string] $context = 'sdpconnection',
    [parameter()]
    [string] $logPath,
    [parameter()]
    [switch] $cleanupOnError,
    [parameter()]
    [switch] $skipCleanup,
    [parameter()]
    [string] $cleanupTag
)

$tag = 'sdk' + (-join ((48..57) + (97..102) | Get-Random -Count 4 | ForEach-Object { [char]$_ }))
if ($cleanupTag) {
    $tag = $cleanupTag
}
if (-not $logPath) {
    $logPath = Join-Path $PSScriptRoot "Test-SDPCrud-$tag.log"
}
$script:failures = New-Object System.Collections.Generic.List[string]
$script:stepCount = 0

# ---------------------------------------------------------------- logging

function Write-Log {
    param([string] $level, [string] $message)
    $line = "[{0}] {1}" -f $level, $message
    $color = switch ($level) {
        'success' {
            'Green'
        }
        'error' {
            'Red'
        }
        'warn' {
            'Yellow'
        }
        'verbose' {
            'DarkGray'
        }
        default {
            'Gray'
        }
    }
    Write-Host $line -ForegroundColor $color
    Add-Content -Path $logPath -Value $line
}

# Runs one step. The scriptblock's verbose/error streams are captured so
# they only get dumped when something goes wrong. -expect gets the result
# and returns $true/$false.

function Invoke-Step {
    param(
        [parameter(Mandatory)] [string] $describe,
        [parameter(Mandatory)] [string] $commandText,
        [parameter(Mandatory)] [scriptblock] $command,
        [parameter()] [scriptblock] $expect,
        [parameter()] [string] $expectText = 'expectation'
    )

    $script:stepCount++
    Write-Log info "> $describe"
    Write-Log info "-> $commandText"

    $stream = New-Object System.Collections.Generic.List[object]
    $result = @()

    try {
        & $command *>&1 | ForEach-Object { $stream.Add($_) }

        $errors = @($stream | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })
        $result = @($stream | Where-Object {
            $_ -isnot [System.Management.Automation.VerboseRecord] -and
            $_ -isnot [System.Management.Automation.ErrorRecord] -and
            $_ -isnot [System.Management.Automation.WarningRecord] -and
            $_ -isnot [System.Management.Automation.InformationRecord]
        })

        if ($errors.Count -gt 0) {
            throw $errors[0]
        }
        if ($expect) {
            $ok = & $expect $result
            if (-not $ok) {
                throw "$expectText (got $($result.Count) result(s))"
            }
        }
        Write-Log success "-> $describe"
    } catch {
        $script:failures.Add($describe)
        Write-Log error "--> $describe"
        Write-Log error "--> $($_.Exception.Message)"
        if ($_.CategoryInfo) {
            Write-Log error "--> category: $($_.CategoryInfo)"
        }
        if ($_.ScriptStackTrace) {
            Write-Log error "--> at: $(($_.ScriptStackTrace -split "`n")[0])"
        }
        $verbose = @($stream | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] })
        if ($verbose.Count -gt 0) {
            Write-Log error "--> verbose stream:"
            foreach ($v in $verbose) {
                Write-Log verbose "      $($v.Message)"
            }
        }
    }

    if ($result.Count -eq 1) {
        return $result[0]
    }
    return $result
}

# ---------------------------------------------------------------- setup

Import-Module (Join-Path $PSScriptRoot '../SDP/sdp.psd1') -Force 3>$null
"=== SDP CRUD test $tag  $(Get-Date -Format s) ===" | Set-Content $logPath
Write-Log info "tag: $tag   log: $logPath"

if ($server) {
    if (-not $credential) {
        $credential = Get-Credential -Message "SDP credential for $server"
    }
    Invoke-Step 'Connect to SDP' "Connect-SDP -server $server -credentials <cred> -context $context" {
        Connect-SDP -server $server -credentials $credential -context $context -Verbose
    } -expect { param($r) $r.state -or $r } -expectText 'system/state came back' | Out-Null
}
if ($context -ne 'sdpconnection') {
    Invoke-Step "Promote $context to default context" "Set-SDPDefaultContext -context $context" {
        Set-SDPDefaultContext -context $context
    } | Out-Null
}

# class methods call Remove-* without -Force so they would prompt, silence that for the run
$oldConfirm = $global:ConfirmPreference
$global:ConfirmPreference = 'None'

Invoke-Step 'Sanity check the session' 'Get-SDPSystemState -Verbose' {
    Get-SDPSystemState -Verbose
} -expect { param($r) $r.Count -ge 1 } -expectText 'system state returned' | Out-Null

if ($script:failures.Count -gt 0) {
    Write-Log error 'no working session, bailing before creating anything'
    $global:ConfirmPreference = $oldConfirm
    return
}

# ---------------------------------------------------------------- cleanup-only mode

if ($cleanupTag) {
    Write-Log info "===== sweeping leftovers tagged $tag (by name, dependency order)"

    Invoke-Step 'Remove group mappings' "Get-SDPHostGroupMapping | where host_name -like $tag* | Remove-SDPHostGroupMapping -Force" {
        Get-SDPHostGroupMapping | Where-Object host_name -like "$tag*" | Remove-SDPHostGroupMapping -Force -Verbose
    } | Out-Null
    Invoke-Step 'Remove host mappings' "Get-SDPHostMapping | where host_name -like $tag* | Remove-SDPHostMapping -Force" {
        Get-SDPHostMapping | Where-Object host_name -like "$tag*" | Remove-SDPHostMapping -Force -Verbose
    } | Out-Null
    Invoke-Step 'Delete thin clones' "Get-SDPVolume | where name -like $tag*clone* | Remove-SDPVolume -Force" {
        Get-SDPVolume | Where-Object name -like "$tag*clone*" | Remove-SDPVolume -Force -Verbose
    } | Out-Null
    Invoke-Step 'Delete view-snapshots' "Get-SDPVolumeGroupSnapshot -asViewSnapshot | where name -like $tag* | Remove-SDPVolumeGroupSnapshot -Force" {
        Get-SDPVolumeGroupSnapshot -asViewSnapshot | Where-Object name -like "$tag*" | Remove-SDPVolumeGroupSnapshot -Force -Verbose
    } | Out-Null
    Invoke-Step 'Delete views' "Get-SDPVolumeGroupView | where name -like $tag* | Remove-SDPVolumeGroupView -Force" {
        Get-SDPVolumeGroupView | Where-Object name -like "$tag*" | Remove-SDPVolumeGroupView -Force -Verbose
    } | Out-Null
    Invoke-Step 'Delete snapshots' "Get-SDPVolumeGroupSnapshot | where name -like $tag* | Remove-SDPVolumeGroupSnapshot -Force" {
        Get-SDPVolumeGroupSnapshot | Where-Object name -like "$tag*" | Remove-SDPVolumeGroupSnapshot -Force -Verbose
    } | Out-Null
    Invoke-Step 'Delete volumes' "Get-SDPVolume | where name -like $tag* | Remove-SDPVolume -Force" {
        Get-SDPVolume | Where-Object name -like "$tag*" | Remove-SDPVolume -Force -Verbose
    } | Out-Null
    Invoke-Step 'Delete volume groups' "Get-SDPVolumeGroup | where name -like $tag* | Remove-SDPVolumeGroup -Force" {
        Get-SDPVolumeGroup | Where-Object name -like "$tag*" | Remove-SDPVolumeGroup -Force -Verbose
    } | Out-Null
    Invoke-Step 'Remove IQNs and hosts' "Get-SDPHost | where name -like $tag* | Remove-SDPHostIqn/Remove-SDPHost -Force" {
        Get-SDPHost | Where-Object name -like "$tag*" | ForEach-Object {
            Remove-SDPHostIqn -hostName $_.name -Force -Verbose -ErrorAction SilentlyContinue
            Remove-SDPHost -id $_.id -Force -Verbose
        }
    } | Out-Null
    Invoke-Step 'Delete host groups' "Get-SDPHostGroup | where name -like $tag* | Remove-SDPHostGroup -Force" {
        Get-SDPHostGroup | Where-Object name -like "$tag*" | Remove-SDPHostGroup -Force -Verbose
    } | Out-Null
    Invoke-Step 'Delete retention policies' "Get-SDPRetentionPolicy | where name -like $tag* | Remove-SDPRetentionPolicy -Force" {
        Get-SDPRetentionPolicy | Where-Object name -like "$tag*" | Remove-SDPRetentionPolicy -Force -Verbose
    } | Out-Null
    Invoke-Step 'Nothing tagged should be left' "Get-SDP* | where name -like $tag*" {
        @(Get-SDPHost) + @(Get-SDPHostGroup) + @(Get-SDPVolumeGroup) + @(Get-SDPVolume) + @(Get-SDPVolumeGroupSnapshot) + @(Get-SDPRetentionPolicy) |
            Where-Object name -like "$tag*"
    } -expect { param($r) $r.Count -eq 0 } -expectText 'zero leftovers' | Out-Null

    $global:ConfirmPreference = $oldConfirm
    Write-Log info "===== summary: $($script:stepCount) steps, $($script:failures.Count) failed"
    foreach ($f in $script:failures) {
        Write-Log error "  $f"
    }
    return
}

# names
$rpName   = "$tag-rp"
$hgName   = "$tag-hg"
$hosts    = @(
    @{ name = "$tag-win1"; type = 'Windows' },
    @{ name = "$tag-win2"; type = 'Windows' },
    @{ name = "$tag-lin1"; type = 'Linux' },
    @{ name = "$tag-lin2"; type = 'Linux' }
)
foreach ($h in $hosts) {
    $h.vg   = "$($h.name)-vg"
    $h.vol1 = "$($h.name)-vol1"
    $h.vol2 = "$($h.name)-vol2"
    $h.iqn  = "iqn.2005-03.org.open-iscsi:$($h.name)"
}
$win1 = $hosts[0]; $win2 = $hosts[1]; $lin1 = $hosts[2]; $lin2 = $hosts[3]

# ---------------------------------------------------------------- build

Write-Log info '===== retention policy'

$rp = Invoke-Step "Create retention policy $rpName" "New-SDPRetentionPolicy -name $rpName -snapshotCount 5 -weeks 0 -days 1 -hours 0 -Verbose" {
    New-SDPRetentionPolicy -name $rpName -snapshotCount 5 -weeks 0 -days 1 -hours 0 -Verbose
} -expect { param($r) $r[0].GetType().Name -eq 'SDPRetentionPolicy' -and $r[0].name -eq $rpName } -expectText 'SDPRetentionPolicy back with the right name'

Write-Log info '===== hosts'

foreach ($h in $hosts) {
    $h.obj = Invoke-Step "Create $($h.type) host $($h.name)" "New-SDPHost -name $($h.name) -type $($h.type) -Verbose" {
        New-SDPHost -name $h.name -type $h.type -Verbose
    } -expect { param($r) $r[0].GetType().Name -eq 'SDPHost' -and $r[0].type -eq $h.type } -expectText "SDPHost of type $($h.type)"

    Invoke-Step "Add IQN to $($h.name)" "Set-SDPHostIqn -hostName $($h.name) -iqn $($h.iqn) -Verbose" {
        Set-SDPHostIqn -hostName $h.name -iqn $h.iqn -Verbose
    } | Out-Null

    Invoke-Step "Read IQN back for $($h.name)" "Get-SDPHostIqn -hostName $($h.name) -Verbose" {
        Get-SDPHostIqn -hostName $h.name -Verbose
    } -expect { param($r) $r.Count -eq 1 -and $r[0].iqn -eq $h.iqn } -expectText 'exactly one IQN matching what we set' | Out-Null
}

Invoke-Step 'Filter hosts by type Linux' "Get-SDPHost -type Linux -Verbose" {
    Get-SDPHost -type Linux -Verbose
} -expect { param($r) ($r | Where-Object name -like "$tag*").Count -eq 2 -and -not ($r | Where-Object type -ne 'Linux') } -expectText 'both linux test hosts and nothing non-linux' | Out-Null

Invoke-Step "Get host by name $($win1.name)" "Get-SDPHost -name $($win1.name) -Verbose" {
    Get-SDPHost -name $win1.name -Verbose
} -expect { param($r) $r.Count -eq 1 -and $r[0].name -eq $win1.name } -expectText 'exactly one host' | Out-Null

Write-Log info '===== volume groups'

foreach ($h in $hosts) {
    $h.vgObj = Invoke-Step "Create volume group $($h.vg)" "New-SDPVolumeGroup -name $($h.vg) -Verbose" {
        New-SDPVolumeGroup -name $h.vg -Verbose
    } -expect { param($r) $r[0].GetType().Name -eq 'SDPVolumeGroup' -and $r[0].name -eq $h.vg } -expectText 'SDPVolumeGroup back'
}

Invoke-Step "Set description on $($win2.vg)" "Set-SDPVolumeGroup -id $($win2.vgObj.id) -Description 'sdk test' -Verbose" {
    Set-SDPVolumeGroup -id $win2.vgObj.id -Description 'sdk test' -Verbose
} | Out-Null

Write-Log info '===== volumes and mappings'

foreach ($h in $hosts) {
    # vol1: cmdlet all the way
    $h.vol1Obj = Invoke-Step "Create $($h.vol1) in $($h.vg)" "New-SDPVolume -name $($h.vol1) -sizeInGB 10 -VolumeGroupName $($h.vg) -Verbose" {
        New-SDPVolume -name $h.vol1 -sizeInGB 10 -VolumeGroupName $h.vg -Verbose
    } -expect { param($r) $r[0].GetType().Name -eq 'SDPVolume' -and $r[0].sizeInGB -eq 10 -and $r[0].volume_group_name -eq $h.vg } -expectText 'SDPVolume, 10GB, in the right VG'

    Invoke-Step "Map $($h.vol1) to $($h.name) by piping the host" "Get-SDPHost -name $($h.name) | New-SDPHostMapping -volumeName $($h.vol1) -Verbose" {
        Get-SDPHost -name $h.name | New-SDPHostMapping -volumeName $h.vol1 -Verbose
    } -expect { param($r) $r.Count -eq 1 -and $r[0].GetType().Name -eq 'SDPHostMapping' -and $r[0].volume_name -eq $h.vol1 } -expectText 'the one new SDPHostMapping back' | Out-Null

    # vol2: pipe the VG in, map with the class method
    $h.vol2Obj = Invoke-Step "Create $($h.vol2) by piping the VG" "Get-SDPVolumeGroup -name $($h.vg) | New-SDPVolume -name $($h.vol2) -sizeInGB 10 -Verbose" {
        Get-SDPVolumeGroup -name $h.vg | New-SDPVolume -name $h.vol2 -sizeInGB 10 -Verbose
    } -expect { param($r) $r[0].GetType().Name -eq 'SDPVolume' -and $r[0].volume_group_name -eq $h.vg } -expectText 'SDPVolume in the right VG'

    Invoke-Step "Map $($h.vol2) to $($h.name) via `$vol.Map()" "`$vol.Map('$($h.name)')" {
        $h.vol2Obj.Map($h.name)
    } | Out-Null

    Invoke-Step "Host $($h.name) should now have 2 mappings" "Get-SDPHost -name $($h.name) | Get-SDPHostMapping -Verbose" {
        Get-SDPHost -name $h.name | Get-SDPHostMapping -Verbose
    } -expect { param($r) $r.Count -eq 2 } -expectText '2 mappings' | Out-Null

    Invoke-Step "VG $($h.vg) should list 2 volumes" "Get-SDPVolumeGroup -name $($h.vg) | Get-SDPVolume -Verbose" {
        Get-SDPVolumeGroup -name $h.vg | Get-SDPVolume -Verbose
    } -expect { param($r) $r.Count -eq 2 } -expectText '2 volumes' | Out-Null
}

Invoke-Step "Mapping lookup by host and volume" "Get-SDPHostMapping -hostName $($win1.name) -volumeName $($win1.vol1) -Verbose" {
    Get-SDPHostMapping -hostName $win1.name -volumeName $win1.vol1 -Verbose
} -expect { param($r) $r.Count -eq 1 -and $r[0].host_name -eq $win1.name -and $r[0].volume_name -eq $win1.vol1 } -expectText 'one mapping with resolved names' | Out-Null

Write-Log info "===== snapshots and views (on $($win1.vg))"

$snapName = "$tag-snap1"
$snap = Invoke-Step "Snapshot $($win1.vg) by piping the VG" "Get-SDPVolumeGroup -name $($win1.vg) | New-SDPVolumeGroupSnapshot -name $snapName -retentionPolicyName $rpName -Verbose" {
    Get-SDPVolumeGroup -name $win1.vg | New-SDPVolumeGroupSnapshot -name $snapName -retentionPolicyName $rpName -Verbose
} -expect { param($r) $r[0].GetType().Name -eq 'SDPVolumeGroupSnapshot' -and $r[0].name -eq "$($win1.vg):$snapName" } -expectText "snapshot named $($win1.vg):$snapName"

Invoke-Step 'Find snapshot by short name' "Get-SDPVolumeGroupSnapshot -short_name $snapName -Verbose" {
    Get-SDPVolumeGroupSnapshot -short_name $snapName -Verbose
} -expect { param($r) $r.Count -eq 1 } -expectText 'one snapshot' | Out-Null

Invoke-Step 'Find snapshot by piping the VG' "Get-SDPVolumeGroup -name $($win1.vg) | Get-SDPVolumeGroupSnapshot -Verbose" {
    Get-SDPVolumeGroup -name $win1.vg | Get-SDPVolumeGroupSnapshot -Verbose
} -expect { param($r) $r.Count -eq 1 -and $r[0].volume_group_name -eq $win1.vg } -expectText 'one snapshot with resolved vg name' | Out-Null

Invoke-Step 'Volsnaps by piping the snapshot' '$snap | Get-SDPVolSnap -Verbose' {
    $snap | Get-SDPVolSnap -Verbose
} -expect { param($r) $r.Count -eq 2 } -expectText 'one volsnap per volume in the VG' | Out-Null

Invoke-Step 'Snapshot Refresh() method' '$snap.Refresh()' {
    $snap.Refresh()
} -expect { param($r) $r[0].id -eq $snap.id } -expectText 'same id back' | Out-Null

$viewName = "$tag-vw"
$view = Invoke-Step "Create view by piping the snapshot" "`$snap | New-SDPVolumeGroupView -name $viewName -retentionPolicyName $rpName -Verbose" {
    $snap | New-SDPVolumeGroupView -name $viewName -retentionPolicyName $rpName -Verbose
} -expect { param($r) $r[0].GetType().Name -eq 'SDPVolumeGroupView' -and $r[0].name -eq "$($win1.vg):$viewName" } -expectText "view named $($win1.vg):$viewName"

Invoke-Step 'Views for the VG' "Get-SDPVolumeGroupView -volumeGroupName $($win1.vg) -Verbose" {
    Get-SDPVolumeGroupView -volumeGroupName $win1.vg -Verbose
} -expect { param($r) $r.Count -eq 1 } -expectText 'one view' | Out-Null

Invoke-Step 'Snapshot list should not include the view' "Get-SDPVolumeGroupSnapshot -volumeGroupName $($win1.vg) -Verbose" {
    Get-SDPVolumeGroupSnapshot -volumeGroupName $win1.vg -Verbose
} -expect { param($r) $r.Count -eq 1 } -expectText 'still one snapshot' | Out-Null

Invoke-Step "Map view to $($win1.name) via cmdlet" "New-SDPHostMapping -hostName $($win1.name) -viewName $($view.name) -Verbose" {
    New-SDPHostMapping -hostName $win1.name -viewName $view.name -Verbose
} -expect { param($r) $r.Count -eq 1 -and $r[0].volume.ref -eq "/snapshots/$($view.id)" } -expectText 'one mapping pointing at the view' | Out-Null

Invoke-Step "Map view to $($lin1.name) via `$view.Map()" "`$view.Map('$($lin1.name)')" {
    $view.Map($lin1.name)
} | Out-Null

Invoke-Step "Snapshot mappings on $($lin1.name)" "Get-SDPHostMapping -hostName $($lin1.name) -asSnapshot -Verbose" {
    Get-SDPHostMapping -hostName $lin1.name -asSnapshot -Verbose
} -expect { param($r) $r.Count -eq 1 } -expectText 'one snapshot mapping' | Out-Null

$vsnapName = "$tag-vs"
$vsnap = Invoke-Step 'Snapshot of the view by piping the view' "`$view | New-SDPVolumeGroupSnapshot -name $vsnapName -retentionPolicyName $rpName -Verbose" {
    $view | New-SDPVolumeGroupSnapshot -name $vsnapName -retentionPolicyName $rpName -Verbose
} -expect { param($r) $r[0].GetType().Name -eq 'SDPVolumeGroupSnapshot' -and $r[0].name -eq "$($win1.vg):$vsnapName" } -expectText "view-snapshot named $($win1.vg):$vsnapName"

Invoke-Step 'List view-snapshots' 'Get-SDPVolumeGroupSnapshot -asViewSnapshot -Verbose' {
    Get-SDPVolumeGroupSnapshot -asViewSnapshot -Verbose
} -expect { param($r) ($r | Where-Object name -like "*$vsnapName").Count -eq 1 } -expectText 'our view-snapshot is in the list' | Out-Null

$cloneName = "$tag-clone1"
$clone = Invoke-Step "Thin clone by piping $($win1.vol1)" "`$vol | New-SDPVolumeThinClone -name $cloneName -volumeGroupName $($win1.vg) -snapshotName $snapName -Verbose" {
    $win1.vol1Obj | New-SDPVolumeThinClone -name $cloneName -volumeGroupName $win1.vg -snapshotName $snapName -Verbose
} -expect { param($r) $r[0].GetType().Name -eq 'SDPVolume' -and $r[0].name -eq $cloneName } -expectText 'clone volume back'

Write-Log info "===== SDPVolume methods (on $($win1.vol2))"

$mv = $win1.vol2Obj
Invoke-Step 'Volume Resize(20)' '$vol.Resize(20)' {
    $mv.Resize(20)
} -expect { param($r) $r[0].sizeInGB -eq 20 } -expectText 'sizeInGB 20 on the object' | Out-Null

Invoke-Step 'Volume Refresh() shows the new size from the array' '$vol.Refresh()' {
    $mv.Refresh()
} -expect { param($r) $r[0].sizeInGB -eq 20 -and $r[0].size -eq (20 * 1024 * 1024) } -expectText 'array agrees it is 20GB' | Out-Null

Invoke-Step 'Volume Unmap()' "`$vol.Unmap('$($win1.name)')" {
    $mv.Unmap($win1.name)
} | Out-Null

Invoke-Step 'Mapping is gone' "Get-SDPHostMapping -hostName $($win1.name) -volumeName $($win1.vol2) -Verbose" {
    Get-SDPHostMapping -hostName $win1.name -volumeName $win1.vol2 -Verbose
} -expect { param($r) $r.Count -eq 0 } -expectText 'no mapping' | Out-Null

Invoke-Step 'Volume Map() again' "`$vol.Map('$($win1.name)')" {
    $mv.Map($win1.name)
} | Out-Null

Invoke-Step 'Mapping is back' "Get-SDPHostMapping -hostName $($win1.name) -volumeName $($win1.vol2) -Verbose" {
    Get-SDPHostMapping -hostName $win1.name -volumeName $win1.vol2 -Verbose
} -expect { param($r) $r.Count -eq 1 } -expectText 'one mapping' | Out-Null

Invoke-Step 'Set-SDPVolume description' "Set-SDPVolume -id $($mv.id) -Description 'sdk test' -Verbose" {
    Set-SDPVolume -id $mv.id -Description 'sdk test' -Verbose
} | Out-Null

Invoke-Step 'Volume ToString()' '$vol.ToString()' {
    $mv.ToString()
} -expect { param($r) $r[0] -like "$($win1.vol2)*" } -expectText 'name in the string' | Out-Null

Write-Log info "===== SDPVolumeGroup methods (on $($win2.vg))"

$mvg = $win2.vgObj
Invoke-Step 'VG AddVolume()' "`$vg.AddVolume('$tag-extra', 5)" {
    $mvg.AddVolume("$tag-extra", 5)
} | Out-Null

Invoke-Step 'VG Refresh() shows 3 volumes' '$vg.Refresh()' {
    $mvg.Refresh()
} -expect { param($r) $r[0].volumes_count -eq 3 } -expectText 'volumes_count 3' | Out-Null

Invoke-Step 'VG SetQuota(100)' '$vg.SetQuota(100)' {
    $mvg.SetQuota(100)
} -expect { param($r) $r[0].quotaInGB -eq 100 } -expectText 'quotaInGB 100' | Out-Null

Invoke-Step 'VG ToString()' '$vg.ToString()' {
    $mvg.ToString()
} -expect { param($r) $r[0] -like "$($win2.vg)*" } -expectText 'name in the string' | Out-Null

Write-Log info "===== SDPHost methods (on $($lin1.name))"

$mh = $lin1.obj
Invoke-Step 'Host UnmapVolume()' "`$host.UnmapVolume('$($lin1.vol1)')" {
    $mh.UnmapVolume($lin1.vol1)
} | Out-Null

Invoke-Step 'Host Refresh() shows 1 volume' '$host.Refresh()' {
    $mh.Refresh()
} -expect { param($r) $r[0].volumes_count -eq 1 } -expectText 'volumes_count 1' | Out-Null

Invoke-Step 'Host MapVolume()' "`$host.MapVolume('$($lin1.vol1)')" {
    $mh.MapVolume($lin1.vol1)
} | Out-Null

Invoke-Step 'Host Refresh() shows 2 volumes' '$host.Refresh()' {
    $mh.Refresh()
} -expect { param($r) $r[0].volumes_count -eq 2 } -expectText 'volumes_count 2' | Out-Null

Invoke-Step 'Host ToString()' '$host.ToString()' {
    $mh.ToString()
} -expect { param($r) $r[0] -like "$($lin1.name)*" } -expectText 'name in the string' | Out-Null

Write-Log info "===== host group (with $($lin2.name))"

$hg = Invoke-Step "Create host group $hgName" "New-SDPHostGroup -name $hgName -Verbose" {
    New-SDPHostGroup -name $hgName -Verbose
} -expect { param($r) $r[0].GetType().Name -eq 'SDPHostGroup' } -expectText 'SDPHostGroup back'

# per-host mappings have to go before the host can join a group
Invoke-Step "Unmap everything from $($lin2.name)" "Get-SDPHost -name $($lin2.name) | Get-SDPHostMapping | Remove-SDPHostMapping -Force -Verbose" {
    Get-SDPHost -name $lin2.name | Get-SDPHostMapping | Remove-SDPHostMapping -Force -Verbose
} | Out-Null

Invoke-Step "Host AssignToGroup()" "`$host.AssignToGroup('$hgName')" {
    $lin2.obj.AssignToGroup($hgName)
} -expect { param($r) $r[0].host_group_name -eq $hgName } -expectText 'host_group_name resolved on the refreshed host' | Out-Null

Invoke-Step 'Hosts in the group' "Get-SDPHostGroup -name $hgName | Get-SDPHost -Verbose" {
    Get-SDPHostGroup -name $hgName | Get-SDPHost -Verbose
} -expect { param($r) $r.Count -eq 1 -and $r[0].name -eq $lin2.name } -expectText 'just lin2' | Out-Null

Invoke-Step "Map $($lin2.vol1) to the group by piping it" "`$hg | New-SDPHostGroupMapping -volumeName $($lin2.vol1) -Verbose" {
    $hg | New-SDPHostGroupMapping -volumeName $lin2.vol1 -Verbose
} -expect { param($r) $r.Count -eq 1 -and $r[0].GetType().Name -eq 'SDPHostGroupMapping' } -expectText 'one SDPHostGroupMapping back' | Out-Null

Invoke-Step 'Group mappings' "Get-SDPHostGroupMapping -hostGroupName $hgName -Verbose" {
    Get-SDPHostGroupMapping -hostGroupName $hgName -Verbose
} -expect { param($r) $r.Count -eq 1 -and $r[0].volume_name -eq $lin2.vol1 } -expectText 'one group mapping with resolved volume name' | Out-Null

Invoke-Step 'Per-host mapping list excludes group mappings' "Get-SDPHostMapping -Verbose" {
    Get-SDPHostMapping -Verbose
} -expect { param($r) -not ($r | Where-Object { $_.host.ref -match '/host_groups/' }) } -expectText 'no host_group refs in the per-host list' | Out-Null

# ---------------------------------------------------------------- teardown

$built = $script:stepCount
$buildFailures = $script:failures.Count
Write-Log info "===== build done: $built steps, $buildFailures failed"

if ($skipCleanup) {
    Write-Log warn "-skipCleanup set, leaving everything tagged $tag on the array"
} elseif ($buildFailures -gt 0 -and -not $cleanupOnError) {
    Write-Log warn "errors logged, leaving everything tagged $tag on the array for inspection (-cleanupOnError to force)"
} else {
    Write-Log info '===== teardown'

    Invoke-Step 'Remove group mapping' "Get-SDPHostGroupMapping -hostGroupName $hgName | Remove-SDPHostGroupMapping -Force -Verbose" {
        Get-SDPHostGroupMapping -hostGroupName $hgName | Remove-SDPHostGroupMapping -Force -Verbose
    } | Out-Null

    Invoke-Step 'Remove view mappings' "Get-SDPHostMapping -asSnapshot | where host in test | Remove-SDPHostMapping -Force -Verbose" {
        Get-SDPHostMapping -asSnapshot | Where-Object host_name -like "$tag*" | Remove-SDPHostMapping -Force -Verbose
    } | Out-Null

    Invoke-Step 'Delete thin clone' "Remove-SDPVolume -name $cloneName -Force -Verbose" {
        Remove-SDPVolume -name $cloneName -Force -Verbose
    } | Out-Null

    Invoke-Step 'Delete view-snapshot via $vsnap.Delete()' '$vsnap.Delete()' {
        $vsnap.Delete()
    } | Out-Null

    Invoke-Step 'Delete view via $view.Delete()' '$view.Delete()' {
        $view.Delete()
    } | Out-Null

    Invoke-Step 'Delete snapshot via $snap.Delete()' '$snap.Delete()' {
        $snap.Delete()
    } | Out-Null

    foreach ($h in $hosts) {
        Invoke-Step "Unmap $($h.name)" "Get-SDPHost -name $($h.name) | Get-SDPHostMapping | Remove-SDPHostMapping -Force -Verbose" {
            Get-SDPHost -name $h.name | Get-SDPHostMapping | Remove-SDPHostMapping -Force -Verbose
        } | Out-Null

        Invoke-Step "Delete volumes in $($h.vg)" "Get-SDPVolumeGroup -name $($h.vg) | Get-SDPVolume | Remove-SDPVolume -Force -Verbose" {
            Get-SDPVolumeGroup -name $h.vg | Get-SDPVolume | Remove-SDPVolume -Force -Verbose
        } | Out-Null

        Invoke-Step "Delete $($h.vg) via `$vg.Delete()" '$vg.Delete()' {
            $h.vgObj.Delete()
        } | Out-Null

        Invoke-Step "Remove IQN from $($h.name)" "Remove-SDPHostIqn -hostName $($h.name) -Force -Verbose" {
            Remove-SDPHostIqn -hostName $h.name -Force -Verbose
        } | Out-Null

        Invoke-Step "Delete host $($h.name) via `$host.Delete()" '$host.Delete()' {
            $h.obj.Delete()
        } | Out-Null
    }

    Invoke-Step "Delete host group via `$hg.Delete()" '$hg.Delete()' {
        $hg.Delete()
    } | Out-Null

    Invoke-Step "Delete retention policy via `$rp.Delete()" '$rp.Delete()' {
        $rp.Delete()
    } | Out-Null

    Invoke-Step 'Nothing tagged should be left' "Get-SDP{Host,HostGroup,VolumeGroup,Volume,VolumeGroupSnapshot,RetentionPolicy} | where name -like $tag*" {
        @(Get-SDPHost) + @(Get-SDPHostGroup) + @(Get-SDPVolumeGroup) + @(Get-SDPVolume) + @(Get-SDPVolumeGroupSnapshot) + @(Get-SDPRetentionPolicy) |
            Where-Object name -like "$tag*"
    } -expect { param($r) $r.Count -eq 0 } -expectText 'zero leftovers' | Out-Null
}

# ---------------------------------------------------------------- summary

$global:ConfirmPreference = $oldConfirm

Write-Log info "===== summary: $($script:stepCount) steps, $($script:failures.Count) failed"
foreach ($f in $script:failures) {
    Write-Log error "  $f"
}
Write-Log info "log written to $logPath"
