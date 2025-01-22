function New-SDPHostMapping {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter()]
        [string] $volumeName,
        [parameter()]
        [Alias('snapshotName')]
        [string] $viewName,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Map a host to an existing volume.     

        .EXAMPLE 
        New-SDPHostMapping -hostName Host01 -volumeName Vol01

        .EXAMPLE 
        Get-SDPHost -name Host01 | New-SDPHostMapping -volumeName Vol01

        .DESCRIPTION
        This function will map a host to any qualifying volume. Accepts piped into from Get-SDPHost

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = 'mappings'
    }

    process{
        ## Special Ops
        
        $hostid = Get-SDPHost -name $hostName -k2context $k2context
        $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostid.id -nestedObject

        if ($hostid.host_) {
            $message = "Host $hostName is a member of a host group, please use New-SDPHostMapping for the parent or select an unused host."
            Write-Error $message
        }

        if ($volumeName) {
            $volumeid = Get-SDPVolume -name $volumeName -k2context $k2context
            $volumePath = ConvertTo-SDPObjectPrefix -ObjectPath "volumes" -ObjectID $volumeid.id -nestedObject
        } elseif ($viewName) {
            $volumeid = Get-SDPVolumeGroupView -name $viewName -k2context $k2context
            $volumePath = ConvertTo-SDPObjectPrefix -ObjectPath "snapshots" -ObjectID $volumeid.id -nestedObject
        } else {
            $message = "Please supply either a -volumeName or -viewName"
            return $message | Write-error
        }

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        $o | Add-Member -MemberType NoteProperty -Name "volume" -Value $volumePath

        $body = $o

        ## Make the call
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -erroraction silentlycontinue -TimeOut 5
        } catch {
            return $Error[0]
        }

        $response = Get-SDPHostMapping -hostName $hostName -volumeName $volumeName -k2context $k2context
        return $response
        
    }
}
