<#
    .SYNOPSIS
    Use this function to create a new Host Group for Silk SDP

    .EXAMPLE
    New-SDPHostGroup -name HostGroup01 -description "Host Group for all Series 1 hosts"

    .DESCRIPTION
    This function allows for the creation of a single Host Group for Silk SDP.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function New-SDPHostGroup {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string] $name,
        [parameter()]
        [string] $description,
        [parameter()]
        [switch] $allowDifferentHostTypes,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "host_groups"
    }

    process {

        # Build the request body

        $body = New-Object psobject
        $body | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        if ($description) {
            $body | Add-Member -MemberType NoteProperty -Name "description" -Value $description
        }
        if ($allowDifferentHostTypes) {
            $body | Add-Member -MemberType NoteProperty -Name "allow_different_host_types" -Value $true
        }

        # POST returns nothing on success — submit and then poll the GET
        # until the new host group appears.

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $name -Get {
            Get-SDPHostGroup -name $name -k2context $k2context
        }

        return $results
    }
}
