function Set-SDPVolume {
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [int] $sizeInGB,
        [parameter()]
        [string] $Description,
        [parameter()]
        [string] $VolumeGroupName,
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

        if ($sizeInGB) {
            [string]$size = ($sizeInGB * 1024 * 1024)
            Write-Verbose "$sizeInGB GB converted to $size"
        }


        if ($VolumeGroupName) {
            Write-Verbose "Working with Volume Group name $VolumeGroupName"
            $vgstats = Get-SDPVolumeGroup -name $VolumeGroupName -k2context $k2context
            if (!$vgstats) {
                Return "No volumegroup named $VolumeGroupName exists."
            } else {
                $vgpath = ConvertTo-SDPObjectPrefix -ObjectPath volume_groups -ObjectID $vgstats.id -nestedObject
            }
        }
        
        # Build the Object
        
        $o = New-Object psobject
        if ($name) {
            $o | Add-Member -MemberType NoteProperty -Name name -Value $name
        }

        if ($size) {
            $o | Add-Member -MemberType NoteProperty -Name size -Value $size
        }
        
        if ($vgpath) {
            $o | Add-Member -MemberType NoteProperty -Name volume_group -Value $vgpath
        }
        
        if ($VMWare) {
            $o | Add-Member -MemberType NoteProperty -Name vmware_support -Value $true
        }

        if ($Description) {
            $o | Add-Member -MemberType NoteProperty -Name description -Value $Description
        }

        if ($ReadOnly) {
            $o | Add-Member -MemberType NoteProperty -Name read_only -Value $true
        }

        $body = $o

        # Call

        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method PATCH -body $body -k2context $k2context 
        return $results
    }

}

