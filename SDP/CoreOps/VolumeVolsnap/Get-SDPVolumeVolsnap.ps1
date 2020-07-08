function Get-SDPVolumeVolsnap {
    param(
        [parameter()]
        [Alias("BaseVolume")]
        [string] $base_volume,
        [parameter()]
        [Alias("CreationTime")]
        [int] $creation_time,
        [parameter()]
        [int] $id,
        [parameter()]
        [Alias("IsDeleted")]
        [bool] $is_deleted,
        [parameter()]
        [Alias("IsExposable")]
        [bool] $is_exposable,
        [parameter()]
        [string] $name,
        [parameter()]
        [Alias("ScsiSn")]
        [int] $scsi_sn,
        [parameter()]
        [Alias("ScsiSuffix")]
        [int] $scsi_suffix,
        [parameter()]
        [Alias("ShortName")]
        [string] $short_name,
        [parameter()]
        [int] $size,
        [parameter()]
        [string] $snapshot,
        [parameter()]
        [string] $source,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "volsnaps"
    }

    process {
        # Query 

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        return $results
    }
}