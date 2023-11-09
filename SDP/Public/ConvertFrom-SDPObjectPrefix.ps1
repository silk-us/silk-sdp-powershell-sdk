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
    $objectPath = $object.ref.split('/')[1 .. $pathlength]
    if ($objectPath.count -gt 1) {
        $objectPath = $objectPath | Join-String -Separator '/'
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
