function Get-SDPHostMapping {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
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
        Use this function to gather information about existing Host mappings.

        .EXAMPLE 
        Get-SDPHostMapping -hostName "Host01"

        .EXAMPLE 
        Get-SDPHost -name "Host01" | Get-SDPHostMapping

        .EXAMPLE 
        Get-SDPHostMapping -hostName "Host01" -asSnapshot

        .DESCRIPTION
        Query for any host mapping on the SDP. This function accepts piped input from Get-SDPHost. 

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

        if ($hostName) {
            $hostObj = Get-SDPHost -name $hostName -k2context $k2context
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject
            $PSBoundParameters.host = $hostPath 
            $PSBoundParameters.remove('hostName') | Out-Null
        }

        # make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context
        if ($asSnapshot) {
            $results = $results | Where-Object {$_.volume -match '/snapshots/'}
        }

        $results = $results | Where-Object {$_.host.ref -notmatch '/host_groups/'}

        return $results

    }

}
