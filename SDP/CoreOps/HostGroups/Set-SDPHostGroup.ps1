function Set-SDPHostGroup {
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
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = "host_groups"
    }

    process{
        $PSBoundParameters | ConvertTo-json | write-verbose
        ## Special Ops

        $o = New-Object psobject
        if ($name) {
            $o | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        }
        if ($description) {
            $o | Add-Member -MemberType NoteProperty -Name "description" -Value $description
        }
        if ($ConnectivityType) {
            $o | Add-Member -MemberType NoteProperty -Name "connectivity_type" -Value $ConnectivityType
        }
        if ($allowDifferentHostTypes -eq $false) {
            $o | Add-Member -MemberType NoteProperty -Name "allow_different_host_types" -Value $false
        } elseif ($allowDifferentHostTypes -eq $true) {
            $o | Add-Member -MemberType NoteProperty -Name "allow_different_host_types" -Value $true
        }


        $body = $o
        
        ## Make the call
        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method PATCH -body $body -k2context $k2context 
        return $results
    }
}
