function Get-SDPHostNqn {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [Alias('name')]
        [string] $hostName,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $nqn,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )
    <#
        .SYNOPSIS
        Returns a list of host NQNs

        .EXAMPLE 
        Get-SDPHostNqn -hostName Host01

        .EXAMPLE 
        Get-SDPHost | where-object {$_.name -like "TestDev*"} | Get-SDPHostNqn

        .DESCRIPTION
        Gets a list of all hosts and their NQNs. Can specify by host or NQN. Accepts piped input from Get-SDPHost

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

    begin {
        $endpoint = "host_nqns"
    }

    process {

        # Special Ops

        if ($hostName) {
            $hostObj = Get-SDPHost -name $hostName
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject
            $PSBoundParameters.host = $hostPath 
            $PSBoundParameters.remove('hostName') | Out-Null
        }
        
        # Query 

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        return $results
    }
}
