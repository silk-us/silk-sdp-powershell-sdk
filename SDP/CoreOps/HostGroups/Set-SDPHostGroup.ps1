<#
    .SYNOPSIS
    Set any existing Host Group settings.

    .EXAMPLE
    Set-SDPHostGroup -id 4 -description "TestDev SQL hosts"

    .EXAMPLE
    Get-SDPHostGroup | where-object {$_.name -like "TestDev*"} | Set-SDPHostGroup -description "TestDev Host Groups"

    .DESCRIPTION
    Use this function to set any host group settings. This function accepts piped input from Get-SDPHostGroup.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Set-SDPHostGroup {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $description,
        [parameter()]
        [string] $ConnectivityType,
        [parameter()]
        [bool] $allowDifferentHostTypes,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = "host_groups"
    }

    process {
        $PSBoundParameters | ConvertTo-Json | Write-Verbose

        # Build the request body

        $body = New-Object psobject
        if ($name) {
            $body | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        }
        if ($description) {
            $body | Add-Member -MemberType NoteProperty -Name "description" -Value $description
        }
        if ($ConnectivityType) {
            $body | Add-Member -MemberType NoteProperty -Name "connectivity_type" -Value $ConnectivityType
        }
        # $false is meaningful here — caller may explicitly want to clear
        # the flag — so check ContainsKey rather than truthiness.
        if ($PSBoundParameters.ContainsKey('allowDifferentHostTypes')) {
            $body | Add-Member -MemberType NoteProperty -Name "allow_different_host_types" -Value $allowDifferentHostTypes
        }

        # Call

        $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method PATCH -body $body -k2context $k2context
        return $results
    }
}
