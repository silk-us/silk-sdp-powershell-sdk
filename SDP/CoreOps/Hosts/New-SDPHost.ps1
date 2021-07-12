function New-SDPHost {
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
        [ValidateSet('Linux','Windows','ESX',IgnoreCase = $false)]
        [string] $type,
        [parameter()]
        [ValidateSet('FC','NVME','ISCSI',IgnoreCase = $false)]
        [string] $connectivityType,
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

        if ($hostGroupId) {
            Write-Verbose "Working with host Group id $hostGroupId"
            $hgstats = Get-SDPhostGroup -id $hostGroupId
            $hgpath = ConvertTo-SDPObjectPrefix -ObjectPath host_groups -ObjectID $hgstats.id -nestedObject
            if (!$hgstats) {
                Return "No hostgroup with ID $hostGroupId exists."
            } 
        } elseif ($hostGroupName) {
            Write-Verbose "Working with host Group name $hostGroupName"
            $hgstats = Get-SDPhostGroup -name $hostGroupName
            $hgpath = ConvertTo-SDPObjectPrefix -ObjectPath host_groups -ObjectID $hgstats.id -nestedObject
            if (!$hgstats) {
                Return "No hostgroup named $hostGroupName exists."
            } 
        }
    
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name 'name' -Value $name
        $o | Add-Member -MemberType NoteProperty -Name 'type' -Value $type
        $o | Add-Member -MemberType NoteProperty -Name "host_group" -Value $hgpath
        if ($connectivityType) {
            $o | Add-Member -MemberType NoteProperty -Name "connectivity_type" -Value $connectivityType
        }

        # end special ops

        $body = $o
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -erroraction silentlycontinue
        } catch {
            return $Error[0]
        }
        
        $results = Get-SDPHost -name $name
        while (!$results) {
            Write-Verbose " --> Waiting on host $name"
            $results = Get-SDPHost -name $name
            Start-Sleep 1
        }

        return $results
    }

}
