function Set-SDPHostMapping {
    param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $hostName,
        [parameter()]
        [int] $lun,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )
    <#

    #>
    begin {
        $endpoint = 'mappings'
    }

    process{
        ## Special Ops
        if ($hostName) {
            $hostid = Get-SDPHost -name $hostName -k2context $k2context
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostid.id -nestedObject
        }

        if ($hostid.host_) {
            $message = "Host $hostName is a member of a host group, please use New-SDPHostMapping for the parent or select an unused host."
            Write-Error $message
        }


        $o = New-Object psobject
        if ($hostName) {
            $o | Add-Member -MemberType NoteProperty -Name "host" -Value $hostPath
        }
        if ($lun) {
            $o | Add-Member -MemberType NoteProperty -Name "lun" -Value $lun
        }

        $body = $o

        ## Make the call
        $endpoint = $endpoint + '/' + $id

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $body -k2context $k2context -erroraction silentlycontinue -TimeOut 5
        } catch {
            return $Error[0]
        }
        $response = Get-SDPHostMapping -lun $lun
        return $response
        
    }
}
