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
    <#
        .SYNOPSIS

        .EXAMPLE 

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
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
