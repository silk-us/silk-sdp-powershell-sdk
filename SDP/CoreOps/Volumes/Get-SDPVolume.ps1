function Get-SDPVolume {
    param(
        [parameter()]
        [string] $description,
        [parameter()]
        [int] $id,
        [parameter(Position=1)]
        [string] $name,
        [parameter()]
        [Alias("VmwareSupport")]
        [bool] $vmware_support,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [Alias("VolumeGroup")]
        [string] $volume_group,
        [parameter()]
        [string] $k2context = "k2rfconnection"
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

        if ($volume_group) {
            Write-Verbose "volume_group specified, parsing KDP Object"
            $PSBoundParameters.volume_group = ConvertTo-SDPObjectPrefix -ObjectPath volume_groups -ObjectID $volume_group -nestedObject
        }

        # Query 

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        return $results
    }
}
