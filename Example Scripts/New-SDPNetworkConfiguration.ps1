param(
    [parameter(Mandatory)]
    [ipaddress] $data1Subnet,
    [parameter(Mandatory)]
    [ipaddress] $data2Subnet,
    [parameter()]
    [ipaddress] $subnetMask = 255.255.255.240,
    [parameter()]
    [ipaddress] $remoteData1Subnet,
    [parameter()]
    [ipaddress] $remoteData2Subnet
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

[ipaddress] $data1Gateway = $data1Subnet.Address + 16777216
[ipaddress] $data2Gateway = $data2Subnet.Address + 16777216

[ipaddress] $data1Interface = $data1Gateway.Address + 16777216
[ipaddress] $data2Interface = $data2Gateway.Address + 16777216

if (Get-SDPSystemNetPorts -name c-node02_dataport01) {
    Get-SDPSystemNetPorts -name c-node02_dataport01 | New-SDPSystemNetIps -ipAddress $data1Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
    Get-SDPSystemNetPorts -name c-node02_dataport02 | New-SDPSystemNetIps -ipAddress $data2Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
}

[ipaddress] $data1Interface = $data1Interface.Address + 16777216
[ipaddress] $data2Interface = $data2Interface.Address + 16777216

if (Get-SDPSystemNetPorts -name c-node03_dataport01) {
    Get-SDPSystemNetPorts -name c-node03_dataport01 | New-SDPSystemNetIps -ipAddress $data1Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
    Get-SDPSystemNetPorts -name c-node03_dataport02 | New-SDPSystemNetIps -ipAddress $data2Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
}

[ipaddress] $data1Interface = $data1Interface.Address + 16777216
[ipaddress] $data2Interface = $data2Interface.Address + 16777216

if (Get-SDPSystemNetPorts -name c-node04_dataport01) {
    Get-SDPSystemNetPorts -name c-node04_dataport01 | New-SDPSystemNetIps -ipAddress $data1Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
    Get-SDPSystemNetPorts -name c-node04_dataport02 | New-SDPSystemNetIps -ipAddress $data2Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
}

[ipaddress] $data1Interface = $data1Interface.Address + 16777216
[ipaddress] $data2Interface = $data2Interface.Address + 16777216

if (Get-SDPSystemNetPorts -name c-node05_dataport01) {
    Get-SDPSystemNetPorts -name c-node05_dataport01 | New-SDPSystemNetIps -ipAddress $data1Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
    Get-SDPSystemNetPorts -name c-node05_dataport02 | New-SDPSystemNetIps -ipAddress $data2Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
}

[ipaddress] $data1Interface = $data1Interface.Address + 16777216
[ipaddress] $data2Interface = $data2Interface.Address + 16777216

if (Get-SDPSystemNetPorts -name c-node06_dataport01) {
    Get-SDPSystemNetPorts -name c-node06_dataport01 | New-SDPSystemNetIps -ipAddress $data1Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
    Get-SDPSystemNetPorts -name c-node06_dataport02 | New-SDPSystemNetIps -ipAddress $data2Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
}

[ipaddress] $data1Interface = $data1Interface.Address + 16777216
[ipaddress] $data2Interface = $data2Interface.Address + 16777216

if (Get-SDPSystemNetPorts -name c-node07_dataport01) {
    Get-SDPSystemNetPorts -name c-node07_dataport01 | New-SDPSystemNetIps -ipAddress $data1Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
    Get-SDPSystemNetPorts -name c-node07_dataport02 | New-SDPSystemNetIps -ipAddress $data2Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
}

[ipaddress] $data1Interface = $data1Interface.Address + 16777216
[ipaddress] $data2Interface = $data2Interface.Address + 16777216

if (Get-SDPSystemNetPorts -name c-node08_dataport01) {
    Get-SDPSystemNetPorts -name c-node08_dataport01 | New-SDPSystemNetIps -ipAddress $data1Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
    Get-SDPSystemNetPorts -name c-node08_dataport02 | New-SDPSystemNetIps -ipAddress $data2Interface.IPAddressToString -subnetMask $subnetMask -service iscsi
}

[ipaddress] $data1Interface = $data1Interface.Address + 16777216
[ipaddress] $data2Interface = $data2Interface.Address + 16777216

if ($remoteData1Subnet) {
    New-SDPStaticRoute -destinationSubnetIp $remoteData1Subnet.IPAddressToString -destinationSubnetMask $subnetMask -gatewayIp $data1Gateway.IPAddressToString
}

if ($remoteData2Subnet) {
    New-SDPStaticRoute -destinationSubnetIp $remoteData2Subnet.IPAddressToString -destinationSubnetMask $subnetMask -gatewayIp $data2Gateway.IPAddressToString
}

