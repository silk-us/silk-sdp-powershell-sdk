function Convert-SDPTimeStampTo {
    param(
        [parameter(Mandatory)]
        [datetime] $timestamp,
        [parameter()]
        [switch] $int
    )

    $epoch = Get-Date -Date "01/01/1970"
    $return = (New-TimeSpan -Start $epoch -End $timestamp.ToUniversalTime()).TotalSeconds
    if ($int) {
        [int]$return = $return
    }
    return $return
}
