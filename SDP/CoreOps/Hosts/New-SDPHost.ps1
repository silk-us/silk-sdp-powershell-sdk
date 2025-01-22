<#
	.SYNOPSIS 
    Create a new host object on the SDP.

	.DESCRIPTION 
    Create a new host object on the SDP.

	.PARAMETER name
	[string] - Provide name for the SDP Host object.

	.PARAMETER type
	[string] - Decalre the host type ('Windows', 'Linux', 'ESX')

	.PARAMETER hostGroupName
	[string] - Set the host's host group via 'name'. 

	.PARAMETER hostGroupID
	[string] - Set the host's host group via 'id'.

	.PARAMETER connectivityType
	[string] - Set the desired host's connectivity type (Unused on Cloud SDP)

	.EXAMPLE
	Create a new host named `WinHost01` and set the host as a `Windows` host type. 
	New-SDPHost -name WinHost01 -type Windows

	.EXAMPLE
	Create a new host named `SQLHost01` and add it to a host group named `SQLCluster01`
	New-SDPHost -name SQLHost01 -type Windows -hostGroupName SQLCluster01

#>
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
        [ValidateSet('FC','NVME','iSCSI',IgnoreCase = $false)]
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
            $hgstats = Get-SDPhostGroup -id $hostGroupId -k2context $k2context
            $hgpath = ConvertTo-SDPObjectPrefix -ObjectPath host_groups -ObjectID $hgstats.id -nestedObject
            if (!$hgstats) {
                Return "No hostgroup with ID $hostGroupId exists."
            } 
        } elseif ($hostGroupName) {
            Write-Verbose "Working with host Group name $hostGroupName"
            $hgstats = Get-SDPhostGroup -name $hostGroupName -k2context $k2context
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
        
        $results = Get-SDPHost -name $name -k2context $k2context
        while (!$results) {
            Write-Verbose " --> Waiting on host $name"
            $results = Get-SDPHost -name $name -k2context $k2context
            Start-Sleep 1
        }

        return $results
    }

}
