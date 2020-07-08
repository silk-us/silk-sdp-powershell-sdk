function ConvertFrom-SDPObjectPrefix {
    param(
        [parameter(Mandatory)]
        [array] $Object,
        [parameter()]
        [switch] $getId
    )

    if ($getID) {
        $return = $object.ref.split('/')[2]
        return $return
    } else {
        $objectPath = $object.ref.split('/')[1]
        $objectId = $object.ref.split('/')[2]
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name 'ObjectPath' -Value $objectPath
        $o | Add-Member -MemberType NoteProperty -Name 'ObjectId' -Value $objectId
        return $o
    }
}
