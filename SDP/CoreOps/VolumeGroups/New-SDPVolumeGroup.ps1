<#
    .SYNOPSIS
    Creates a new volume group on the SDP.

    .DESCRIPTION
    Creates a new volume group on the Silk Data Pod. Volume groups are
    containers for volumes that share capacity policies, quotas, and
    snapshot schedules.

    .PARAMETER name
    The name for the new volume group.

    .PARAMETER quotaInGB
    Optional capacity quota for the volume group in gigabytes. Omit for
    unlimited quota.

    .PARAMETER enableDeDuplication
    Enables deduplication for all volumes in this volume group.

    .PARAMETER Description
    Optional description for the volume group.

    .PARAMETER capacityPolicy
    Name of the capacity policy to apply to this volume group.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    New-SDPVolumeGroup -name "VG01"

    .EXAMPLE
    New-SDPVolumeGroup -name "VG02" -quotaInGB 5000 -enableDeDuplication

    .EXAMPLE
    New-SDPVolumeGroup -name "VG03" -capacityPolicy "Policy01" -Description "Production volumes"

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPVolumeGroup {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ValidateLength(0, 42)]
        [string] $name,
        [parameter()]
        [int] $quotaInGB,
        [parameter()]
        [switch] $enableDeDuplication,
        [parameter()]
        [string] $Description,
        [parameter()]
        [string] $capacityPolicy,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "volume_groups"
    }

    process {

        # Special Ops

        if ($quotaInGB) {
            [string] $quota = ($quotaInGB * 1024 * 1024)
        }

        if ($capacityPolicy) {
            $capacityPolicyObj = Get-SDPVgCapacityPolicies -k2context $k2context | Where-Object { $_.name -eq $capacityPolicy }
            $capacityPolicyRef = ConvertTo-SDPObjectPrefix -ObjectID $capacityPolicyObj.id -ObjectPath vg_capacity_policies -nestedObject
        }

        # Build the request body
        # Quota defaults to 0 (unlimited) when -quotaInGB isn't passed.

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        if ($quotaInGB) {
            $body | Add-Member -MemberType NoteProperty -Name "quota" -Value $quota
        } else {
            $body | Add-Member -MemberType NoteProperty -Name "quota" -Value 0
        }
        if ($Description) {
            $body | Add-Member -MemberType NoteProperty -Name "description" -Value $Description
        }
        if ($capacityPolicyRef) {
            $body | Add-Member -MemberType NoteProperty -Name "capacity_policy" -Value $capacityPolicyRef
        }
        if ($enableDeDuplication) {
            $body | Add-Member -MemberType NoteProperty -Name "is_dedup" -Value $true
        }

        # POST returns nothing on success — submit and then poll the GET
        # until the new volume group appears.

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $name -Get {
            Get-SDPVolumeGroup -name $name -k2context $k2context
        }

        return $results
    }
}
