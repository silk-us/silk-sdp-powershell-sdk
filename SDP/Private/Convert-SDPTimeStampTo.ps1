function Convert-SDPTimeStampTo {
    param(
        [parameter(Mandatory)]
        [datetime] $timestamp,
        [parameter()]
        [switch] $int,
        [parameter()]
        [switch] $useLocalTime
    )

    $epoch = Get-Date -Date "01/01/1970"
    if ($useLocalTime) {
        $return = (New-TimeSpan -Start $epoch -End $timestamp).TotalSeconds
    } else {
        $return = (New-TimeSpan -Start $epoch -End $timestamp.ToUniversalTime()).TotalSeconds
    }
    if ($int) {
        [int]$return = $return
    }
    return $return
}
