# v2 Release Notes

A handful of changes that affect existing automation. Read these before upgrading.

## Default output rendering

The module now ships with `SDP.format.ps1xml`, which defines table views for every
resource class (volumes, volume groups, hosts, host groups, snapshots, retention
policies, etc.). Listing cmdlets like `Get-SDPVolume` now print a clean
fixed-column table by default — `id`, `name`, ref-resolved names, and the columns
most operators actually look at — instead of a wall of properties. Pipe to
`Format-List *` (or `Select-Object *`) any time you need the full payload.

## Automatic ref-name resolution

The API returns related objects as opaque `{ ref, id }` pointers (e.g. a volume's
`volume_group` field). `Update-SDPRefObjects` now runs automatically against
listing returns and attaches the resolved name alongside the ref —
`volume_group_name`, `retention_policy_name`, `host_group_name`, and so on. These
resolved properties are what the new format views display, and they're available
for filtering and pipelining without an extra round-trip:

```powershell
Get-SDPVolume | Where-Object volume_group_name -eq 'TestDemo'
```

If you have automation that needs the raw, unresolved shape, pass `-doNotResolve`
on the listing cmdlet.

## Class-backed return types

Sixteen resources now return strongly-typed objects (`SDPVolume`,
`SDPVolumeGroup`, `SDPHost`, `SDPHostGroup`, `SDPHostMapping`, `SDPHostIqn`,
`SDPHostNqn`, `SDPHostPwwn`, `SDPHostGroupMapping`, `SDPVolSnap`,
`SDPVolumeGroupSnapshot`, `SDPVolumeGroupView`, `SDPVgCapacityPolicy`,
`SDPRetentionPolicy`, `SDPSystemStats`, `SDPVolumeStats`) instead of raw
hashtables. Existing property access still works — these are additive — but you
can also call instance methods directly. For example:

```powershell
$vol = Get-SDPVolume -name MyVol01
$vol.Resize(500)              # set sizeInGB to 500
$vol.Map('Host01')            # map to a host
$vol.SetReadOnly()            # flip read_only
$vol.Refresh()                # re-fetch latest state from the array
$vol.Delete()                 # delete the volume
```

The methods wrap the same `Set-`, `New-`, and `Remove-` cmdlets you already know,
so the underlying API contract is unchanged.

## Deprecated cmdlets

The volume-group **view-snapshot** trio has been removed:

- `Get-SDPVolumeGroupViewSnapshot`
- `New-SDPVolumeGroupViewSnapshot`
- `Remove-SDPVolumeGroupViewSnapshot`

The platform treats view snapshots as ordinary volume-group snapshots, so all
three are now served by the regular `*-SDPVolumeGroupSnapshot` cmdlets - point
them at a view's parent VG and they behave identically. Any scripts calling the
removed cmdlets will need a one-line rename.
