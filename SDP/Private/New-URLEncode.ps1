function New-URLEncode {
    param(
        [parameter(Mandatory)]
        [string] $URL,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    $server = Get-Variable -Scope Global -Name $k2context -ValueOnly

    $baseurl = 'https://' + $server.K2Endpoint
    $url = $url.Replace($baseurl,$null)
    $url = $url.Replace(':','%3A').replace('.','%2E')
    $url = $baseurl + $url
    # write-verbose "-- Invoke-SDPRestCall --> New-URLEncode -> Using URLEncode $url"
    return $url
}