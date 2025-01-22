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

        if ($asSnapshot) {
            Write-Verbose 'removing asSnapshot from parameter list.'
            $PSBoundParameters.remove('asSnapshot') | Out-Null
        }

        # special ops

        if ($volumeName) {
            $volumeObj = Get-SDPVolume -name $volumeName -k2context $k2context
            $volumePath = ConvertTo-SDPObjectPrefix -ObjectPath "volumes" -ObjectID $volumeObj.id -nestedObject
            $PSBoundParameters.volume = $volumePath 
            $PSBoundParameters.remove('volumeName') | Out-Null
        }

        if ($hostGroupName) {
            $hostGroupObj = Get-SDPHostGroup -name $hostGroupName -k2context $k2context
            $hostGroupPath = ConvertTo-SDPObjectPrefix -ObjectPath "host_groups" -ObjectID $hostGroupObj.id -nestedObject
            $PSBoundParameters.host = $hostGroupPath 
            $PSBoundParameters.remove('hostGroupName') | Out-Null
        }

        # make the call

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        if ($asSnapshot) {
            $results = $results | Where-Object {$_.volume -match '/snapshots/'}
        } 

        $results = $results | Where-Object {$_.host.ref -match '/host_groups/'}

        return $results
    }

}
