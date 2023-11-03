function Set-SDPHostNqn {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $nqn,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Assigns an NQN to a host. 

        .EXAMPLE 
        Set-SDPHostNqn -hostName Host01 -Nqn Nqn.1998-01.com.vmware.iscsi:0123456789ABCDEF

        .EXAMPLE 
        Get-SDPHost -name Host01 | Set-SDPHostNqn -Nqn Nqn.1998-01.com.vmware.iscsi:0123456789ABCDEF

        .DESCRIPTION
        Set's the NQN for any host. Accepts piped input from Get-SDPHost. 

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = 'host_nqns'
    }

    process{
        ## Special Ops

        $hostid = Get-SDPHost -name $hostname -k2context $k2context
        $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath 'hosts' -ObjectID $hostid.id -nestedObject

        # Build the Object
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "nqn" -Value $nqn
        $o | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        
        $body = $o

        ## Make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        return $results
    }
    
    
}

