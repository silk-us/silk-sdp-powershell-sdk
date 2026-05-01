<#
    .SYNOPSIS
    Map a host to an existing volume.

    .DESCRIPTION
    Maps a host to a qualifying volume or volume group view (snapshot).
    Accepts piped input from Get-SDPHost.

    .PARAMETER hostName
    Name of the host to map. Accepts piped input from Get-SDPHost.

    .PARAMETER volumeName
    Name of the volume to expose to the host. Mutually exclusive with
    -viewName.

    .PARAMETER viewName
    Name of the volume group view (snapshot) to expose. Mutually exclusive
    with -volumeName.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    New-SDPHostMapping -hostName Host01 -volumeName Vol01

    .EXAMPLE
    Get-SDPHost -name Host01 | New-SDPHostMapping -volumeName Vol01

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPHostMapping {
    [CmdletBinding()]
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

    begin {
        $endpoint = 'mappings'
    }

    process {

        # Special Ops — resolve host and target (volume or view) to refs.

        $hostObj = Get-SDPHost -name $hostName -k2context $k2context
        $hostRef = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject

        if ($hostObj.host_) {
            Write-Error "Host $hostName is a member of a host group, please use New-SDPHostMapping for the parent or select an unused host."
        }

        if ($volumeName) {
            $volumeObj = Get-SDPVolume -name $volumeName -k2context $k2context
            $volumeRef = ConvertTo-SDPObjectPrefix -ObjectPath "volumes" -ObjectID $volumeObj.id -nestedObject
        } elseif ($viewName) {
            $volumeObj = Get-SDPVolumeGroupView -name $viewName -k2context $k2context
            $volumeRef = ConvertTo-SDPObjectPrefix -ObjectPath "snapshots" -ObjectID $volumeObj.id -nestedObject
        } else {
            return "Please supply either a -volumeName or -viewName" | Write-Error
        }

        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "host" -Value $hostRef
        $body | Add-Member -MemberType NoteProperty -Name "volume" -Value $volumeRef

        # Call

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue -TimeOut 5
        } catch {
            return $Error[0]
        }

        $response = Get-SDPHostMapping -hostName $hostName -volumeName $volumeName -k2context $k2context
        return $response
    }
}
