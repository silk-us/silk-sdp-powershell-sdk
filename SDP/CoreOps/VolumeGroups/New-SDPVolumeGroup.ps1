<#
    .SYNOPSIS
    Creates a new volume group on the SDP.

    .DESCRIPTION
    Creates a new volume group on the Silk Data Pod. Volume groups are containers for volumes that share capacity policies, quotas, and snapshot schedules.

    .PARAMETER name
    The name for the new volume group.

    .PARAMETER quotaInGB
    Optional capacity quota for the volume group in gigabytes. Set to 0 for unlimited quota.

    .PARAMETER enableDeDuplication
    Enables deduplication for all volumes in this volume group.

    .PARAMETER Description
    Optional description for the volume group.

    .PARAMETER capacityPolicy
    Name of the capacity policy to apply to this volume group.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    New-SDPVolumeGroup -name "VG01"
    Creates a basic volume group named "VG01" with no quota.

    .EXAMPLE
    New-SDPVolumeGroup -name "VG02" -quotaInGB 5000 -enableDeDuplication
    Creates a volume group with a 5TB quota and deduplication enabled.

    .EXAMPLE
    New-SDPVolumeGroup -name "VG03" -capacityPolicy "Policy01" -Description "Production volumes"
    Creates a volume group with a capacity policy and description.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function New-SDPVolumeGroup {
    param(
        [parameter(Mandatory)]
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
    
    Process {
        ## Special Ops

        if ($quotaInGB) {
            [string]$size = ($quotaInGB * 1024 * 1024)
        }
        
        if ($capacityPolicy) {
            $cappolstats = Get-SDPVgCapacityPolicies -k2context $k2context | Where-Object {$_.name -eq $capacityPolicy}
            $cappol = ConvertTo-SDPObjectPrefix -ObjectID $cappolstats.id -ObjectPath vg_capacity_policies -nestedObject
        }


        ## Build the object

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        if ($quota) {
            $o | Add-Member -MemberType NoteProperty -Name "quota" -Value $size
        } else {
            $o | Add-Member -MemberType NoteProperty -Name "quota" -Value 0
        }
        if ($Description) {
            $o | Add-Member -MemberType NoteProperty -Name "description" -Value $Description
        }
        if ($capacityPolicy) {
            $o | Add-Member -MemberType NoteProperty -Name "capacity_policy" -Value $cappol
        }
        if ($enableDeDuplication) {
            $o | Add-Member -MemberType NoteProperty -Name "is_dedup" -Value $true
        }
        
        $body = $o

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }
        
        $results = Get-SDPVolumeGroup -name $name -k2context $k2context
        while (!$results) {
            Write-Verbose " --> Waiting on volume group $name"
            $results = Get-SDPVolumeGroup -name $name -k2context $k2context
            Start-Sleep 1
        }

        return $results
    }
    
}
