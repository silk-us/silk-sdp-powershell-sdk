function Convert-SDPTimeStampTo {
    param(
        [parameter(Mandatory)]
        [datetime] $timestamp
    )

    $epoch = Get-Date -Date "01/01/1970"
    return (New-TimeSpan -Start $epoch -End $timestamp.ToUniversalTime()).TotalSeconds
}
