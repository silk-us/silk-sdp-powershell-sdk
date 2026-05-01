<#
    .SYNOPSIS
    Modify an existing host's properties.

    .DESCRIPTION
    Updates name, type, or host group assignment on an existing host.

    .PARAMETER id
    The unique identifier of the host. Accepts piped input from Get-SDPHost.

    .PARAMETER name
    New name for the host.

    .PARAMETER type
    New host type. Valid choices: Linux, Windows, ESX, AIX, Solaris.

    .PARAMETER hostGroupName
    Move the host into a different host group, by name.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    Set-SDPHost -id 20 -name WinHost02

    .EXAMPLE
    Get-SDPHost -name WinHost01 | Set-SDPHost -name WinHost02

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPHost {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $hostGroupName,
        [parameter()]
        [string] $name,
        [parameter()]
        [ValidateSet('Linux','Windows','ESX','AIX','Solaris',IgnoreCase = $false)]
        [string] $type,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "hosts"
    }

    process {

        # Special Ops — resolve host group ref if a name was supplied.

        if ($hostGroupName) {
            $hostGroup = Get-SDPHostGroup -name $hostGroupName -k2context $k2context
            $hostGroupRef = ConvertTo-SDPObjectPrefix -ObjectID $hostGroup.id -ObjectPath host_groups -nestedObject
        }

        # Build the request body

        $body = New-Object psobject
        if ($name) {
            $body | Add-Member -MemberType NoteProperty -Name 'name' -Value $name
        }
        if ($type) {
            $body | Add-Member -MemberType NoteProperty -Name 'type' -Value $type
        }
        if ($hostGroupRef) {
            $body | Add-Member -MemberType NoteProperty -Name 'host_group' -Value $hostGroupRef
        }

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method PATCH -body $body -k2context $k2context
        return $results
    }
}
