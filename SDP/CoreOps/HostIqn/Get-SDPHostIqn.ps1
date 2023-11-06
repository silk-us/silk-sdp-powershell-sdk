function Get-SDPHostIqn {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [Alias('name')]
        [string] $hostName,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $iqn,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    <#
        .SYNOPSIS
        Returns a list of host IQNs

        .EXAMPLE 
        Get-SDPHostIqn -hostName Host01

        .EXAMPLE 
        Get-SDPHost | where-object {$_.name -like "TestDev*"} | Get-SDPHostIqn

        .DESCRIPTION
        Gets a list of all hosts and their IQNs. Can specify by host or IQN. Accepts piped input from Get-SDPHost

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

    begin {
        $endpoint = "host_iqns"
    }

    process {

        # Special Ops

        if ($hostName) {
            $hostObj = Get-SDPHost -name $hostName -k2context $k2context
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject
            $PSBoundParameters.host = $hostPath 
            $PSBoundParameters.remove('hostName') | Out-Null
        }
        
        # Query 

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        return $results
    }
}
