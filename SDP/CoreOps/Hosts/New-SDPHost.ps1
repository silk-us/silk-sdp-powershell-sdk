<#
    .SYNOPSIS
    Create a new host object on the SDP.

    .DESCRIPTION
    Create a new host object on the SDP, optionally placed into an existing
    host group at creation time.

    .PARAMETER name
    Name for the new host.

    .PARAMETER type
    Host type. Valid choices: Linux, Windows, ESX, AIX, Solaris.

    .PARAMETER hostGroupName
    Optional host group to assign by name.

    .PARAMETER hostGroupId
    Optional host group to assign by ID. Accepts piped input from
    Get-SDPHostGroup.

    .PARAMETER connectivityType
    Optional connectivity type (FC, NVME, iSCSI). Unused on Cloud SDP.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to
    'k2rfconnection'.

    .EXAMPLE
    New-SDPHost -name WinHost01 -type Windows

    .EXAMPLE
    New-SDPHost -name SQLHost01 -type Windows -hostGroupName SQLCluster01

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPHost {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [Alias("hostGroup")]
        [string] $hostGroupName,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $hostGroupId,
        [parameter(Mandatory)]
        [string] $name,
        [parameter(Mandatory)]
        [ValidateSet('Linux','Windows','ESX','AIX','Solaris',IgnoreCase = $false)]
        [string] $type,
        [parameter()]
        [ValidateSet('FC','NVME','iSCSI',IgnoreCase = $false)]
        [string] $connectivityType,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "hosts"
    }

    process {

        # Special Ops — resolve the optional target host group (by id or name).

        if ($hostGroupId) {
            Write-Verbose "Working with host group id $hostGroupId"
            $hostGroup = Get-SDPHostGroup -id $hostGroupId -k2context $k2context
            if (!$hostGroup) {
                return "No host group with ID $hostGroupId exists."
            }
            $hostGroupRef = ConvertTo-SDPObjectPrefix -ObjectPath host_groups -ObjectID $hostGroup.id -nestedObject
        } elseif ($hostGroupName) {
            Write-Verbose "Working with host group name $hostGroupName"
            $hostGroup = Get-SDPHostGroup -name $hostGroupName -k2context $k2context
            if (!$hostGroup) {
                return "No host group named $hostGroupName exists."
            }
            $hostGroupRef = ConvertTo-SDPObjectPrefix -ObjectPath host_groups -ObjectID $hostGroup.id -nestedObject
        }

        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name 'name' -Value $name
        $body | Add-Member -MemberType NoteProperty -Name 'type' -Value $type
        if ($hostGroupRef) {
            $body | Add-Member -MemberType NoteProperty -Name 'host_group' -Value $hostGroupRef
        }
        if ($connectivityType) {
            $body | Add-Member -MemberType NoteProperty -Name 'connectivity_type' -Value $connectivityType
        }

        # POST returns nothing on success — submit and then poll the GET
        # until the new host appears.

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $name -Get {
            Get-SDPHost -name $name -k2context $k2context
        }

        return $results
    }
}
