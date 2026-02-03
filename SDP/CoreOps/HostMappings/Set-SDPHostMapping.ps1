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

    process{
        ## Special Ops
        if ($hostName) {
            $hostid = Get-SDPHost -name $hostName -k2context $k2context
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostid.id -nestedObject
        }

        if ($hostid.host_) {
            $message = "Host $hostName is a member of a host group, please use New-SDPHostMapping for the parent or select an unused host."
            Write-Error $message
        }


        $o = New-Object psobject
        if ($hostName) {
            $o | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        }
        if ($lun) {
            $o | Add-Member -MemberType NoteProperty -Name "lun" -Value $lun
        }

        $body = $o

        ## Make the call
        $endpointURI = $endpoint + '/' + $id

        try {
            Invoke-SDPRestCall -endpoint $endpointURI -method PATCH -body $body -k2context $k2context -erroraction silentlycontinue -TimeOut 5
        } catch {
            return $Error[0]
        }
        $response = Get-SDPHostMapping -lun $lun
        return $response
        
    }
}
