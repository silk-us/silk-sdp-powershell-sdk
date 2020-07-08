function ConvertTo-SDPObjectPrefix {
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $ObjectID,
        [parameter(Mandatory)]
        [ValidateSet('volumes','volume_groups','hosts','host_groups','snapshots','vg_capacity_policies','retention_policies','replication/peer_k2arrays','replication/sessions','system/net_ports',IgnoreCase = $false)]
        [string] $ObjectPath,
        [parameter()]
        [switch] $blank,
        [parameter()]
        [switch] $nestedObject,
        [parameter()]
        [switch] $compact
    )

    if ($blank) {
        $hostprefix = $null
    } else {
        $hostprefix = '/' + $ObjectPath + '/' + $ObjectID
    }
    
    if ($nestedObject) {
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name 'ref' -Value $hostprefix
        return $o
    } elseif ($compact) {
        $hostprefix = '@{ref=/' + $ObjectPath + '/' + $ObjectID + '}'
        return $hostprefix
    } else {
        return $hostprefix
    }
}
