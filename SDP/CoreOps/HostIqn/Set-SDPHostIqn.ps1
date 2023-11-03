function Set-SDPHostIqn {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $iqn,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Assigns an IQN to a host. 

        .EXAMPLE 
        Set-SDPHostIqn -hostName Host01 -iqn iqn.1998-01.com.vmware.iscsi:0123456789ABCDEF

        .EXAMPLE 
        Get-SDPHost -name Host01 | Set-SDPHostIqn -iqn iqn.1998-01.com.vmware.iscsi:0123456789ABCDEF

        .DESCRIPTION
        Set's the IQN for any host. Accepts piped input from Get-SDPHost. 

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = 'host_iqns'
    }

    process{
        ## Special Ops

        $hostid = Get-SDPHost -name $hostname -k2context $k2context
        $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath 'hosts' -ObjectID $hostid.id -nestedObject

        # Build the Object
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "iqn" -Value $iqn
        $o | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        
        $body = $o

        ## Make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context 
        return $results
    }
    
    
}

