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
        [bool] $enableDeDuplication = $false,
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