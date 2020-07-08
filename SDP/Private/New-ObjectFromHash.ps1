function New-ObjectFromHash {
    param(
        [parameter()]
        [hashtable] $inputHash,
        [parameter()]
        [array] $ignoreArray
    )

    $body = New-Object psobject
    foreach ($i in $inputHash.keys) {
        $par = $i
        $val = $inputHash[$i]
        if ($ignoreArray -notcontains $par) {
            $body | Add-Member -MemberType NoteProperty -Name $par -Value $val
        }
    }
    return $body
}