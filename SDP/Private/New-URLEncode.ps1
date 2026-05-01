function New-URLEncode {
    param(
        [parameter(Mandatory)]
        [string] $URL,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    $server = Get-Variable -Scope Global -Name $k2context -ValueOnly -ErrorAction SilentlyContinue

    if (-not $server) {
        throw "New-URLEncode: No variable found for k2context '$k2context'. Please ensure you have logged in with the correct context or specify the correct context variable name."   
    } else {
        Write-Verbose "New-URLEncode: Found variable for k2context '$k2context'. Using its K2Endpoint value for URL encoding."  
    }

    $baseurl = 'https://' + $server.K2Endpoint
    $url = $url.Replace($baseurl,$null)
    $url = $url.Replace(':','%3A').replace('.','%2E')
    $url = $baseurl + $url
    # write-verbose "-- Invoke-SDPRestCall --> New-URLEncode -> Using URLEncode $url"
    return $url
}