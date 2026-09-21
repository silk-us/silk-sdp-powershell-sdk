function New-SDPHostGroupMapping {
    [CmdletBinding()]
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName','name')]
        [string] $hostGroupName,
        [parameter()]
        [string] $volumeName,
        [parameter()]
        [string] $snapshotName,
        [parameter()]
        [string] $context = 'sdpconnection'
    )
    <#
        .SYNOPSIS
        Map a host group to an existing volume.

        .EXAMPLE
        New-SDPHostGroupMapping -hostGroupName HG01 -volumeName Vol01

        .EXAMPLE
        Get-SDPHostGroup -name HG01 | New-SDPHostGroupMapping -volumeName Vol01

        .DESCRIPTION
        This function will map a host group to any qualifying volume. Accepts piped into from Get-SDPHostGroup

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://github.com/silk-us/silk-sdp-powershell-sdk

    #>
    begin {
        $endpoint = 'mappings'
    }

    process{
        ## Special Ops

        $hostGroupid = Get-SDPHostGroup -name $hostGroupName -context $context -doNotResolve
        if (!$hostGroupid) {
            Write-Error "No host group named $hostGroupName exists."
            return
        }
        $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "host_groups" -ObjectID $hostGroupid.id -nestedObject

        if ($volumeName) {
            $volumeid = Get-SDPVolume -name $volumeName -context $context
            $volumePath = ConvertTo-SDPObjectPrefix -ObjectPath "volumes" -ObjectID $volumeid.id -nestedObject
        } elseif ($snapshotName) {
            $volumeid = Get-SDPVolumeGroupSnapshot -name $snapshotName -context $context
            $volumePath = ConvertTo-SDPObjectPrefix -ObjectPath "snapshots" -ObjectID $volumeid.id -nestedObject
        } else {
            $message = "Please supply either a -volumeName or -snapshotName"
            return $message | Write-error
        }

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        $o | Add-Member -MemberType NoteProperty -Name "volume" -Value $volumePath

        $body = $o

        ## Make the call
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -context $context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity "$hostGroupName -> $($volumePath.ref)" -Get {
            Get-SDPHostGroupMapping -hostGroupName $hostGroupName -context $context -doNotResolve |
                Where-Object { $_.volume.ref -eq $volumePath.ref }
        }
        return ($results | Update-SDPRefObjects -context $context)
        # return $body

    }
}
