<#
	.SYNOPSIS 
    Set an existing host's properties. 

	.DESCRIPTION 
    Set an existing host's properties. 

	.PARAMETER id
	[string] - 'id' value of the desired host. This can be piped via 'Get-SDPHost'

	.PARAMETER name
	[string] - Name value to set for the specified host. 

	.PARAMETER type
	[string] - Decalre the host type ('Windows', 'Linux', 'ESX')

	.PARAMETER hostGroupName
	[string] - Set the host's host group via 'name'. 

	.PARAMETER hostGroupID
	[string] - Set the host's host group via 'id'.

	.EXAMPLE
	Set values for a host with the `id` of `20`.
	Set-SDPHost -id 20 -Name WinHost02

	.EXAMPLE
	Rename a host named `WinHost01` to `WinHost02`. 
	Get-SDPHost -name WinHost01 | Set-SDPHost -name WinHost02

#>
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
            $hostGroup = Get-SDPHostGroup -name $hostGroupName -k2context $k2context
            $opt = ConvertTo-SDPObjectPrefix -ObjectID $hostGroup.id -ObjectPath host_groups -nestedObject
            $o | Add-Member -MemberType NoteProperty -Name 'host_group' -Value $opt
        }

        $body = $o 

        $endpointURI = $endpoint + '/' + $id
        $results = Invoke-SDPRestCall -endpoint $endpointURI -method PATCH -body $body -k2context $k2context 
        return $results
    }
}