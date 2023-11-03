function New-SDPVolume {
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [int] $sizeInGB,
        [parameter()]
        [string] $VolumeGroupName,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $volumeGroupId,
        [parameter()]
        [switch] $VMWare,
        [parameter()]
        [string] $Description,
        [parameter()]
        [switch] $ReadOnly,
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
        $endpoint = "volumes"
    }

    process {

        # Special Ops

        if ($volumeGroupId) {
            Write-Verbose "Working with Volume Group id $volumeGroupId"
            $vgstats = Get-SDPVolumeGroup -id $volumeGroupId -k2context $k2context
            if (!$vgstats) {
                Return "No volumegroup with ID $volumeGroupId exists."
            } 
        } elseif ($VolumeGroupName) {
            Write-Verbose "Working with Volume Group name $VolumeGroupName"
            $vgstats = Get-SDPVolumeGroup -name $VolumeGroupName -k2context $k2context
            if (!$vgstats) {
                Return "No volumegroup named $VolumeGroupName exists."
            } 
        }
        try {
            $vgid = $vgstats.id
            Write-Verbose "Volume Group ID = $vgid"
            $vgpath = ConvertTo-SDPObjectPrefix -ObjectPath volume_groups -ObjectID $vgstats.id -nestedObject
        } catch {
            return "No volume_group discovered"
        }

        ## Build the object

        [string]$size = ($sizeInGB * 1024 * 1024)
        Write-Verbose "$sizeInGB GB converted to $size"
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        $o | Add-Member -MemberType NoteProperty -Name "size" -Value $size
        $o | Add-Member -MemberType NoteProperty -Name "volume_group" -Value $vgpath
        if ($VMWare) {
            $o | Add-Member -MemberType NoteProperty -Name vmware_support -Value $true
        }
        if ($Description) {
            $o | Add-Member -MemberType NoteProperty -Name description -Value $Description
        }
        if ($ReadOnly) {
            $o | Add-Member -MemberType NoteProperty -Name read_only -Value $true
        }

        # Call 

        $body = $o
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }
        
        $results = Get-SDPVolume -name $name
        while (!$results) {
            Write-Verbose " --> Waiting on volume $name"
            $results = Get-SDPVolume -name $name
            Start-Sleep 1
        }

        return $results
    }
}
