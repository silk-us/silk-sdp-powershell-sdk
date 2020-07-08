function Get-SDPHostGroupMapping {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostGroupName,
        [parameter()]
        [int] $id,
        [parameter()]
        [int] $lun,
        [parameter()]
        [Alias("UniqueTarget")]
        [bool] $unique_target,
        [parameter()]
        [string] $volumeName,
        [parameter()]
        [switch] $asSnapshot,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Use this function to gather information about existing Host Group mappings.

        .EXAMPLE 
        Get-SDPHostGroupMapping -hostGroupName "HostGroup01"

        .EXAMPLE 
        Get-SDPHostGroup -name "HostGroup01" | Get-SDPHostGroupMapping

        .DESCRIPTION
        Query for any host group mapping on the SDP. This function accepts piped input from Get-SDPHostGroup. 

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    
    begin {
        $endpoint = "mappings"
    }
    
    process {
        # parameter cleanup
        <#
        if ($hostName) {
            $PSBoundParameters.host = $PSBoundParameters.hostref 
            $PSBoundParameters.remove('hostref') | Out-Null
        }
        #>

        # special ops

        if ($volumeName) {
            $volumeObj = Get-SDPVolume -name $volumeName
            $volumePath = ConvertTo-SDPObjectPrefix -ObjectPath "volumes" -ObjectID $volumeObj.id -nestedObject
            $PSBoundParameters.volume = $volumePath 
            $PSBoundParameters.remove('volumeName') | Out-Null
        }

        if ($hostGroupName) {
            $hostGroupObj = Get-SDPHostGroup -name $hostGroupName
            $hostGroupPath = ConvertTo-SDPObjectPrefix -ObjectPath "host_groups" -ObjectID $hostGroupObj.id -nestedObject
            $PSBoundParameters.host = $hostGroupPath 
            $PSBoundParameters.remove('hostGroupName') | Out-Null
        }

        # make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        return $results
    }

}
