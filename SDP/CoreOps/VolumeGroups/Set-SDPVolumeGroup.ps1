<#
    .SYNOPSIS
    Modifies properties of an existing volume group.

    .DESCRIPTION
    Updates configuration settings for an existing volume group on the Silk Data Pod. Can modify name, quota, description, and capacity policy.

    .PARAMETER id
    The unique identifier of the volume group to modify. Accepts piped input from Get-SDPVolumeGroup.

    .PARAMETER name
    New name for the volume group.

    .PARAMETER quotaInGB
    New capacity quota for the volume group in gigabytes. Set to 0 for unlimited quota.

    .PARAMETER Description
    New description for the volume group.

    .PARAMETER capacityPolicy
    Name of a new capacity policy to apply to this volume group.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Set-SDPVolumeGroup -id 15 -quotaInGB 10000
    Sets the quota for volume group ID 15 to 10TB.

    .EXAMPLE
    Get-SDPVolumeGroup -name "VG01" | Set-SDPVolumeGroup -name "VG01-Renamed"
    Renames a volume group using piped input.

    .EXAMPLE
    Set-SDPVolumeGroup -id 15 -capacityPolicy "NewPolicy"
    Applies a new capacity policy to the volume group.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Set-SDPVolumeGroup {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [array] $id,
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

        if ($quotaInGB) {
            [string]$size = ($quotaInGB * 1024 * 1024)
        }
        
        if ($capacityPolicy) {
            $cappolstats = Get-SDPVgCapacityPolicies -k2context $k2context | Where-Object {$_.name -eq $capacityPolicy}
            $cappol = ConvertTo-SDPObjectPrefix -ObjectID $cappolstats.id -ObjectPath vg_capacity_policies -nestedObject
        }


        # Build the object

        $o = New-Object psobject
        if ($name) {
            $o | Add-Member -MemberType NoteProperty -Name name -Value $name
        }
        if 
        ($quotaInGB) {
            $o | Add-Member -MemberType NoteProperty -Name quota -Value $size
        } else {
            $o | Add-Member -MemberType NoteProperty -Name quota -Value 0
        }
        
        if ($Description) {
            $o | Add-Member -MemberType NoteProperty -Name description -Value $Description
        }
        if ($capacityPolicy) {
            $o | Add-Member -MemberType NoteProperty -Name capacity_policy -Value $cappol
        }

        $o | Add-Member -MemberType NoteProperty -Name is_dedupe -Value $enableDeDuplication


        $body = $o 

        $endpointURI = $endpoint + '/' + $id

        $endpointURI | write-verbose
        
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method PATCH -body $body -k2context $k2context 
        return $results
    }
}