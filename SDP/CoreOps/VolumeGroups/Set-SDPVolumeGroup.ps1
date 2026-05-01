<#
    .SYNOPSIS
    Modifies properties of an existing volume group.

    .DESCRIPTION
    Updates configuration settings for an existing volume group on the
    Silk Data Pod. Can modify name, quota, description, and capacity
    policy.

    .PARAMETER id
    The unique identifier of the volume group to modify. Accepts piped
    input from Get-SDPVolumeGroup.

    .PARAMETER name
    New name for the volume group.

    .PARAMETER quotaInGB
    New capacity quota in gigabytes. Pass 0 to set unlimited quota.

    .PARAMETER Description
    New description for the volume group.

    .PARAMETER capacityPolicy
    Name of a capacity policy to apply to this volume group.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Set-SDPVolumeGroup -id 15 -quotaInGB 10000

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01" | Set-SDPVolumeGroup -name "VG01-Renamed"

    .EXAMPLE
    Set-SDPVolumeGroup -id 15 -capacityPolicy "NewPolicy"

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPVolumeGroup {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $quotaInGB,
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

        if ($PSBoundParameters.ContainsKey('quotaInGB')) {
            [string] $quota = ($quotaInGB * 1024 * 1024)
        }

        if ($capacityPolicy) {
            $capacityPolicyObj = Get-SDPVgCapacityPolicies -k2context $k2context | Where-Object { $_.name -eq $capacityPolicy }
            $capacityPolicyRef = ConvertTo-SDPObjectPrefix -ObjectID $capacityPolicyObj.id -ObjectPath vg_capacity_policies -nestedObject
        }

        # Build the request body — only include fields the caller actually
        # passed, so PATCH doesn't clobber unrelated values.

        $body = New-Object psobject
        if ($name) {
            $body | Add-Member -MemberType NoteProperty -Name name -Value $name
        }
        if ($PSBoundParameters.ContainsKey('quotaInGB')) {
            $body | Add-Member -MemberType NoteProperty -Name quota -Value $quota
        }
        if ($Description) {
            $body | Add-Member -MemberType NoteProperty -Name description -Value $Description
        }
        if ($capacityPolicyRef) {
            $body | Add-Member -MemberType NoteProperty -Name capacity_policy -Value $capacityPolicyRef
        }

        # Call

        Write-Verbose "$endpoint/$id"
        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method PATCH -body $body -k2context $k2context
        return $results
    }
}
