param(
    [parameter(Mandatory)]
    [string] $SDPHost,
    [parameter(Mandatory)]
    [string] $configName
)

<#
    .SYNOPSIS 
    Creates a full zoning feed-file to enter into a Brocade FC Switch, using the existing Host and SDP FC port PWWNs via SDK queries. 

    .EXAMPLE
    (After connecting to the SDP via Connect-SDP)
    ./Create-HostFCZone-Brocade.ps1 -SDPHost ESX01 -configName k2n_cfg

    This will dump the raw commands out to console, as well as save it in a file named (in this example) ESX01-fc-config for later parsing with ssh automation to the switch. 

#>

$SDPPorts = Get-SDPSystemFcPorts
$hostPorts = Get-SDPHost -name $SDPHost | Get-SDPHostPwwn

$cmdlist = @()
foreach ($i in $SDPPorts) {
    $endName = $i.name.replace("-",$null)
    $command = "alicreate " + $endName + ", " + $i.pwwn
    $cmdlist += $command
}

$startport = 1
foreach ($i in $hostPorts) {
    $portname = $SDPHost + "_" + $startport
    $startport++
    $command = "alicreate " + $portname + ","  + $i.pwwn 
    $cmdlist += $command
}


foreach ($i in $SDPPorts) {
    $endName = $i.name.replace("-",$null)
    $startport = 1
    foreach ($z in $hostPorts) {
        $portname = $SDPHost + "_" + $startport
        $startport++
        $zonename = $endName + "__" + $portname
        $command = "zonecreate " + $zonename + ", " + "`"" + $endName + "`; " + $portname + "`""
        $cmdlist += $command
        $command = "cfgadd " + $configName + ", " + $zonename 
        $cmdlist += $command
    }
}

$cmdlist += "cfgsave"
$command = "cfgenable " + $configName
$cmdlist += $command

$configFileName = $SDPHost + "-fc-config"
$cmdlist | Out-File $configFileName

return $cmdlist