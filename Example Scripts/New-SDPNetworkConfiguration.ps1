param(
    [parameter(Mandatory)]
    [ipaddress] $data1Subnet,
    [parameter()]
    [ipaddress] $data2Subnet,
    [parameter()]
    [ipaddress] $subnetMask = 255.255.255.240,
    [parameter()]
    [ipaddress] $remoteData1Subnet,
    [parameter()]
    [ipaddress] $remoteData2Subnet,
    [parameter()]
    [ipaddress] $remoteDataSubnetMask = $subnetMask,
    [parameter()]
    [ipaddress] $data1Gateway,
    [parameter()]
    [ipaddress] $data2Gateway
)

<#
    .EXAMPLE 
    New-SDPNetworkConfiguration.ps1 -data1Subnet 10.0.2.0 -data2Subnet 10.0.3.0

    This will:
        - Configure any available iSCSI data ports on the SDP.

    .EXAMPLE 
    New-SDPNetworkConfiguration.ps1 -data1Subnet 10.0.2.0 -data2Subnet 10.0.3.0 -remoteData1Subnet 192.168.2.0 remoteData2Subnet 192.168.3.0

    This will:
        - Configure any available iSCSI data ports on the SDP.
        - Configure routes to the remote data subnets. 


#>

$dataPorts = Get-SDPSystemNetPorts | Where-Object {$_.name -match "dataport0"}

foreach ($i in $dataPorts) {
    [string]$ipid = $i.name.Split('_')[0][-1]
    [string]$dpid = $i.name[-1]
    $ipup = 16777216 * $ipid
    if ($dpid -eq "1") {
        [ipaddress]$ipint = $data1Subnet.Address + $ipup   
        Get-SDPSystemNetPorts -name $i.name | New-SDPSystemNetIps -ipAddress $ipint.IPAddressToString -subnetMask $subnetMask -service iscsi     
    } else {
        if ($data2Subnet) {
            [ipaddress]$ipint = $data2Subnet.Address + $ipup
            Get-SDPSystemNetPorts -name $i.name | New-SDPSystemNetIps -ipAddress $ipint.IPAddressToString -subnetMask $subnetMask -service iscsi
        }
    }
}
if ($remoteData1Subnet) {
    New-SDPStaticRoute -destinationSubnetIp $remoteData1Subnet.IPAddressToString -destinationSubnetMask $remoteDataSubnetMask -gatewayIp $data1Gateway.IPAddressToString
}

if ($remoteData2Subnet) {
    New-SDPStaticRoute -destinationSubnetIp $remoteData2Subnet.IPAddressToString -destinationSubnetMask $remoteDataSubnetMask -gatewayIp $data2Gateway.IPAddressToString
}

