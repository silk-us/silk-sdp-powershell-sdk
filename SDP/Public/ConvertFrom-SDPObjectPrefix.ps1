function ConvertFrom-SDPObjectPrefix {
    param(
        [parameter(Mandatory)]
        [array] $Object,
        [parameter()]
        [switch] $getId
    )

    
    $pathlength = $object.ref.Split('/').count
    $pathlength-- 

    $objectId = $object.ref.split('/')[$pathlength]

    $pathlength--
    
    if ($pathlength -gt 1) {
        $objectPath = $object.ref.split('/')[1 .. $pathlength]
        $objectPath = $objectPath | Join-String -Separator '/'
    } else {
        $objectPath = $object.ref.split('/')[1]
    }
    $o = New-Object psobject
    $o | Add-Member -MemberType NoteProperty -Name 'ObjectPath' -Value $objectPath
    $o | Add-Member -MemberType NoteProperty -Name 'ObjectId' -Value $objectId

    if ($getId) {
        return $objectId
    } else {
        return $o
    }
    
}
