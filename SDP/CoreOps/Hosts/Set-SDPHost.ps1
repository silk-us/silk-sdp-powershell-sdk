function Set-SDPHost {
    param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $hostGroupName,
        [parameter()]
        [string] $name,
        [parameter()]
        [ValidateSet('Linux','Windows','ESX',IgnoreCase = $false)]
        [string] $type,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    <#
        .SYNOPSIS

        .EXAMPLE 

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = "hosts"
    }

    process {        
        $o = New-Object psobject
        if ($name) {
            $o | Add-Member -MemberType NoteProperty -Name 'name' -Value $name
        }
        if ($type) {
            $o | Add-Member -MemberType NoteProperty -Name 'type' -Value $type
        }
        if ($hostGroupName) {
            $hostGroup = Get-SDPHostGroup -name $hostGroupName
            $opt = ConvertTo-SDPObjectPrefix -ObjectID $hostGroup.id -ObjectPath host_groups -nestedObject
            $o | Add-Member -MemberType NoteProperty -Name 'host_group' -Value $opt
        }

        $body = $o 

        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method PATCH -body $body -k2context $k2context 
        return $results
    }
}