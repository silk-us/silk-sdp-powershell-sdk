function New-SDPSystemNetIps {
    param(
        [parameter(Mandatory)]
        [IPAddress] $ipAddress, 
        [parameter(Mandatory)]
        [IPAddress] $subnetMask,
        [parameter(Mandatory)]
        [ValidateSet('iscsi','Replication', IgnoreCase = $false)]
        [string] $service,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $interface,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#
        .SYNOPSIS
        Configures an IP address for a specific interface

        .EXAMPLE 
        Get-SDPSystemNetPorts -name c-node02_dataport01 | New-SDPSystemNetIps -ipAddress 10.100.5.2 -subnetMask 255.255.255.0 -service iscsi

        .DESCRIPTION
        This function will configure an IP for a desired NetPort. The allowed service types are going to be 'iscsi' and 'replication'. This function accepts piped input from the Get-SDPSystemNetPorts function. 

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    

    begin {
        $endpoint = "system/net_ips"
    }

    process{
        ## Special Ops

        $interfacePath = ConvertTo-SDPObjectPrefix -ObjectPath 'system/net_ports' -ObjectID $interface -nestedObject

        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "ip_address" -Value $ipAddress.IPAddressToString
        $o | Add-Member -MemberType NoteProperty -Name "network_mask" -Value $subnetMask.IPAddressToString
        $o | Add-Member -MemberType NoteProperty -Name "service" -Value $service
        $o | Add-Member -MemberType NoteProperty -Name "interface" -Value $interfacePath

        # Make the call 

        $body = $o
        
        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -erroraction silentlycontinue
            Start-Sleep 1
        } catch {
            return $Error[0]
        }

        $results = Get-SDPSystemNetIps -ip_address $ipAddress.IPAddressToString

        if ($results) {
            return $results
        } else {
            $message = "Unable to assign IP $ipAddress to network interface. Please check the specified IP." 
            return $message | Write-Error
        }
        

    }
}

