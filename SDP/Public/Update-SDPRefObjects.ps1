<#
    .SYNOPSIS
    Walks an SDP object's `ref` properties and attaches resolved-name
    NoteProperties (e.g. `volume_group_name`).

    .DESCRIPTION
    For each property on the input object that has a `.ref` sub-property
    (the SDP API's nested-object reference shape), look up the referenced
    resource via the appropriate Get-SDP* cmdlet and attach the resolved
    .name back to the object as `{prop}_name`.

    Dispatch table is provided by Build-SDPPathFunctions. Lookups within
    a single pipeline are cached so listing 100 volumes in the same
    volume group only fetches that volume group's name once. Inner
    Get-SDP* calls pass -doNotResolve to prevent recursive ref-chasing
    across the whole object graph.

    .PARAMETER object
    Pipeline input. Any object with `ref`-shaped properties.

    .PARAMETER k2context
    K2 context name. Threaded through to the inner Get-SDP* lookup so
    multi-context callers resolve names against the right SDP.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Update-SDPRefObjects {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        [psobject] $object,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $pathFunction = Build-SDPPathFunctions
        $refCache = @{}
        Write-Verbose "-- Update-SDPRefObjects -> begin"
    }

    process {
        if ($null -eq $object) { return }

        foreach ($propInfo in $object.PSObject.Properties) {
            $prop = $propInfo.Name
            $candidate = $object.$prop

            # Strict shape check: only single, non-array objects whose
            # .ref is a non-empty string qualify as a resolvable SDP ref.
            #
            # PowerShell's member-access broadcast can make
            # `$object.$prop.ref` truthy on arrays whose elements don't
            # actually carry a .ref (e.g. user_tags), which then produces
            # cascading null errors inside ConvertFrom-SDPObjectPrefix.
            # Filtering out arrays / null / non-string refs up front
            # prevents that.
            if ($null -eq $candidate)         { continue }
            if ($candidate -is [array])       { continue }
            if (-not $candidate.PSObject)     { continue }

            $ref = $candidate.ref
            if ($ref -isnot [string])         { continue }
            if ([string]::IsNullOrWhiteSpace($ref)) { continue }
            if (-not $ref.StartsWith('/'))    { continue }

            Write-Verbose "--> Found ref for property $prop -> $ref"
            $cacheKey = $ref

            if ($refCache.ContainsKey($cacheKey)) {
                $objectName = $refCache[$cacheKey]
            } else {
                $objectDetails = ConvertFrom-SDPObjectPrefix -Object $candidate
                $queryFunction = $pathFunction[$objectDetails.ObjectPath]

                if (!$queryFunction) {
                    Write-Verbose "--> No resolver registered for path '$($objectDetails.ObjectPath)'; skipping"
                    continue
                }

                # Inner call: -doNotResolve prevents recursive
                # Update-SDPRefObjects from cascading across nested
                # refs (e.g. resolving a volume_group then trying to
                # resolve that group's capacity_policy, etc.).
                $objectName = (& $queryFunction -id $objectDetails.ObjectId -k2context $k2context -doNotResolve).name
                $refCache[$cacheKey] = $objectName
            }

            $propertyName = $prop + '_name'
            $object | Add-Member -MemberType NoteProperty -Name $propertyName -Value $objectName -Force
        }

        return $object
    }
}
