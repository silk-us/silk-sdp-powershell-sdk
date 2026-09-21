# v2 Release Notes

A handful of changes that affect existing automation. Read these before upgrading.

## Default output rendering

The module now ships with `SDP.format.ps1xml`, which defines table views for every
resource class (volumes, volume groups, hosts, host groups, snapshots, retention
policies, etc.). Listing cmdlets like `Get-SDPVolume` now print a clean
fixed-column table by default — `id`, `name`, ref-resolved names, and the columns
most operators actually look at — instead of a wall of properties. Pipe to
`Format-List *` (or `Select-Object *`) any time you need the full payload.

## Server-side filtering (v2.1)

Listing cmdlets now send their filters to the API as a query string instead of
pulling the whole collection and filtering client side. Ref-typed filters go out
as `{field}.ref=/path/id` (e.g. `host.ref=/hosts/1`), lists as `{field}__in=a,b`,
everything else as plain `{field}=value`. Piped lookups like
`Get-SDPHost -name X | Get-SDPHostMapping` now return only that host's mappings
straight from the API.

Two knock-on effects:

- `__limit=9999` is only sent on unfiltered listings. Filtered calls use the API
  default (100). Pass `-limit` to `Invoke-SDPRestCall` if you need more.
- A misspelled filter key returns zero hits, not an error. The API silently
  ignores nothing and matches nothing.

`Invoke-SDPRestCall -legacyFilter` restores the old fetch-everything-and-filter
behavior (including the `.ref` parser) for testing. `-strictURI` and
`-strictString` are now no-ops.

`New-*` cmdlets no longer leak a leading `$null` into their output, so
`$vol = New-SDPVolume ...` gives you the SDPVolume directly and its methods work.

## Other v2.1 fixes

- Piping class instances works again. The class objects never carried the old
  `pipeId`/`pipeName` properties, so `Get-SDPVolumeGroup | New-SDPVolume`,
  `Get-SDPHostGroup | Get-SDPHost`, `Get-SDPHost | New-SDPHostMapping`,
  `$snap | New-SDPVolumeGroupView`, `$snap | Get-SDPVolSnap`,
  `$vol | New-SDPVolumeThinClone`, `$vg | New-SDPVolumeGroupSnapshot` and
  `$view | New-SDPVolumeGroupSnapshot` all bind properly now.
- `New-SDPHostMapping` and `New-SDPHostGroupMapping` return the mapping they
  created (previously the request body, or every mapping on the host).
- `New-SDPVolumeGroupSnapshot -viewName` polls for the name the API actually
  assigns (`vg:short_name`, same prefix as the view) instead of timing out.
- `Get-SDPVolumeGroupView` and `Get-SDPVolumeGroupSnapshot -asViewSnapshot`
  classify records correctly when the parent snapshot isn't in the filtered
  result set (one extra `id__in` lookup for missing parents).
- Class methods that delete or unmap (`$vol.Delete()`, `$vol.Unmap()`, etc.)
  pass `-Force` to the underlying cmdlet so they never block on a confirm
  prompt. The cmdlets themselves still prompt without `-Force`.
- `New-SDPVolumeThinClone` threads `-context`, looks the snapshot up by
  `vg:short_name` or short name (was a regex over every snapshot), and uses
  the standard wait helper.
- `Get-SDPVolSnap` honours `-id` and `-name` (they were silently ignored).
- `New-SDPReplicationSession` threads `-context` to its lookups.

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
$vol.Unmap('Host01')          # remove the host mapping
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
