<#
    .SYNOPSIS
    Modifies properties of an existing host mapping.

    .DESCRIPTION
    Updates configuration settings for an existing host mapping on the Silk Data Pod. Can change the host assignment or LUN number for the mapping.

    .PARAMETER id
    The unique identifier of the host mapping to modify. This is a mandatory parameter.

    .PARAMETER hostName
    Change the mapping to a different host by specifying the host name.

    .PARAMETER lun
    Change the LUN number for the mapping. Valid range is 1-254.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Set-SDPHostMapping -id 123 -lun 5
    Changes the LUN number for mapping ID 123 to LUN 5.

    .EXAMPLE
    Get-SDPHostMapping -hostName "Host01" | Set-SDPHostMapping -lun 10
    Changes the LUN number for a mapping using piped input.

    .EXAMPLE
    Set-SDPHostMapping -id 123 -hostName "Host02"
    Moves the mapping to a different host.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPHostMapping {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [string] $id,
        [parameter()]
        [string] $hostName,
        [parameter()]
        [ValidateRange(1,254)]
        [int] $lun,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'mappings'
    }

    process {

        # Special Ops — resolve host name to a nested ref.

        if ($hostName) {
            $hostObj = Get-SDPHost -name $hostName -k2context $k2context -doNotResolve
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject

            if ($hostObj.host_) {
                Write-Error "Host $hostName is a member of a host group, please use New-SDPHostMapping for the parent or select an unused host."
            }
        }

        # Build the request body

        $body = New-Object psobject
        if ($hostName) {
            $body | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        }
        if ($lun) {
            $body | Add-Member -MemberType NoteProperty -Name "lun" -Value $lun
        }

        # Call

        try {
            Invoke-SDPRestCall -endpoint "$endpoint/$id" -method PATCH -body $body -k2context $k2context -ErrorAction SilentlyContinue -TimeOut 5
        } catch {
            return $Error[0]
        }

        $response = Get-SDPHostMapping -lun $lun -k2context $k2context
        return $response
    }
}
