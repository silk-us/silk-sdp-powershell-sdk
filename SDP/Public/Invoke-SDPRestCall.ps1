<#
    .SYNOPSIS
    Custom rest call for Kaminario K2 platform

    .DESCRIPTION
    GET filters are sent to the API as a query string built from -parameterList.
    The api wants bare key=value for equality, key__in=a,b for lists, and
    key.ref=/path/id for nested ref fields. All of that is derived from the
    parameter list here so cmdlets just hand over $PSBoundParameters.

    -legacyFilter fetches the whole collection (__limit) and filters client
    side the old way, including the .ref parser. Kept for testing/validation.

    .EXAMPLE
    (after logging into a K2)
    Invoke-SDPRestCall -endpoint volume_groups -method GET
    This will return the .hits return for the https://{k2Server}/api/v2/volume_groups API endpoint using the method GET.

    .EXAMPLE
    Invoke-SDPRestCall -endpoint volume -method PATCH -body $body -context TestDev
    This will render the .hits return for the https://{k2Server}/api/v2/volumes API endpoint.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Invoke-SDPRestCall {
    param(
        [parameter(Mandatory)]
        [string] $endpoint,
        [parameter(Mandatory)]
        [ValidateSet('GET','POST','PATCH','DELETE')]
        [string] $method,
        [parameter()]
        [array] $body,
        [parameter()]
        [hashtable] $parameterList,
        [parameter()]
        [string] $context = 'sdpconnection',
        [parameter()]
        [int] $limit = 9999,
        [parameter()]
        [switch] $legacyFilter,
        [parameter()]
        [switch] $strictURI,
        [parameter()]
        [switch] $strictString,
        [parameter()]
        [array] $strictURIgte,
        [parameter()]
        [array] $strictURIlte,
        [parameter()]
        [switch] $noLimit,
        [parameter()]
        [switch] $fullResponse,
        [parameter()]
        [int] $timeOut = 15
    )

    # strictURI / strictString are no-ops now, server side filtering is the default.
    # left in so older callers dont blow up.

    $endpointURI = (New-SDPURI -endpoint $endpoint -context $context).TrimEnd('?','&')

    # drop the common params and context so we only walk real filters

    if ($parameterList) {
        foreach ($p in [System.Management.Automation.PSCmdlet]::CommonParameters) {
            $parameterList.Remove($p) | Out-Null
        }
        $parameterList.Remove('context') | Out-Null
    }

    # Build the query string for GET. Goes out via -Body which Invoke-RestMethod
    # turns into a url encoded query string for us.
    #
    #   @{ref=/hosts/1}  ->  host.ref=/hosts/1
    #   array            ->  key__in=a,b,c
    #   int (gte/lte)    ->  key__gt / key__lt
    #   everything else  ->  key=value
    #
    # __limit only gets added when there are no filters, otherwise the api
    # default is fine (filtered sets are small). Pass -limit explicitly to force it.

    $queryParams = @{}

    if ($method -eq 'GET' -and -not $legacyFilter) {
        if ($parameterList -and $parameterList.Count -gt 0) {
            Write-Verbose "-- REST using parameters --"
            $parameterList | ConvertTo-Json -Depth 10 | Write-Verbose

            foreach ($p in $parameterList.Keys) {
                $value = $parameterList[$p]
                if ($null -eq $value) {
                    continue
                }

                if ($value -is [array]) {
                    $queryParams.Add("${p}__in", ($value -join ','))
                } elseif ($value.ref) {
                    $queryParams.Add("$p.ref", $value.ref)
                } elseif ($value -is [int] -and $strictURIgte -contains $p) {
                    $queryParams.Add("${p}__gt", $value)
                } elseif ($value -is [int] -and $strictURIlte -contains $p) {
                    $queryParams.Add("${p}__lt", $value)
                } else {
                    $queryParams.Add($p, $value)
                }
            }
        }

        if (-not $noLimit -and ($queryParams.Count -eq 0 -or $PSBoundParameters.ContainsKey('limit'))) {
            $queryParams.Add('__limit', $limit)
        }

        if ($queryParams.Count -gt 0) {
            Write-Verbose "-- REST query string --"
            $queryParams | ConvertTo-Json -Depth 10 | Write-Verbose
        }
    } elseif ($method -eq 'GET' -and -not $noLimit) {
        # legacy, grab everything and filter below
        $endpointURI = $endpointURI + '?__limit=' + $limit
        if ($parameterList -and $parameterList.Count -gt 0) {
            Write-Verbose "-- REST using parameters (legacy post-fetch filter) --"
            $parameterList | ConvertTo-Json -Depth 10 | Write-Verbose
        }
    }

    # JSON body for POST/PATCH.

    if ($body) {
        $bodyjson = $body | ConvertTo-Json -Depth 10
        Write-Verbose "-- REST Using following JSON body --"
        Write-Verbose $bodyjson
    }

    Write-Verbose "Invoke-SDPRestCall --> Requesting $method from $endpointURI <--- Final URI"

    # declare the requested context's credential information

    $restContext = Get-Variable -Scope Global -Name $context -ValueOnly -ErrorAction SilentlyContinue
    if (-not $restContext) {
        Write-Error "No SDP session found for context '$context'. Run 'Connect-SDP' (or pass -context <name> if you connected with a custom context name)." -Category AuthenticationError
        return
    }

    # Make the call.

    $resolveRestException = {
        param($errorRecord)

        $statusCode = $null
        if ($errorRecord.Exception.Response) {
            try {
                $statusCode = [int]$errorRecord.Exception.Response.StatusCode
            } catch {

            }
        }

        # Case 1: HTTP success, deserializer choked on empty body.
        if ($statusCode -and $statusCode -ge 200 -and $statusCode -lt 300) {
            Write-Verbose "Invoke-RestMethod threw on empty-body HTTP $statusCode; treating as success."
            return $true
        }

        # Case 2: real failure. Build the most informative message we can.
        $detailMsg = $errorRecord.ErrorDetails.Message
        $msg = $null
        if (-not [string]::IsNullOrWhiteSpace($detailMsg)) {
            try {
                $parsed = $detailMsg | ConvertFrom-Json -ErrorAction Stop
                if ($parsed.error_msg) {
                    $msg = $parsed.error_msg
                } else {
                    $msg = $detailMsg
                }
            } catch {
                $msg = $detailMsg
            }
        }
        if (-not $msg) {
            if ($statusCode) {
                $msg = "API request failed with HTTP $statusCode and no response body."
            } else {
                $msg = $errorRecord.Exception.Message
            }
        }
        Write-Error $msg
        return $false
    }

    $restSplat = @{
        Method     = $method
        Uri        = $endpointURI
        Credential = $restContext.credentials
        TimeoutSec = $timeOut
    }
    if ($body) {
        $restSplat.Body        = $bodyjson
        $restSplat.ContentType = 'application/json'
    } elseif ($queryParams.Count -gt 0) {
        $restSplat.Body = $queryParams
    }

    if ($PSVersionTable.PSEdition -eq 'Core') {
        $restSplat.SkipCertificateCheck = $true
    } elseif ($PSVersionTable.PSEdition -eq 'Desktop') {
        if ([System.Net.ServicePointManager]::CertificatePolicy -notlike 'TrustAllCertsPolicy') {
            Write-Verbose "Correcting certificate policy"
            Unblock-CertificatePolicy
        }
        if ([Net.ServicePointManager]::SecurityProtocol -notmatch 'Tls12') {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol + 'Tls12'
        }
    }

    try {
        $results = Invoke-RestMethod @restSplat
    } catch {
        if (& $resolveRestException $_) {
            $results = $null
        } else {
            return
        }
    }

    if ($fullResponse) {
        return $results
    } else {
        $results = $results.hits
    }

    # LEgacy post-fetch filter - no longer used. Kept for testing, only invoked if -legacyFilter is specified.

    if ($legacyFilter -and $parameterList.Count -gt 0) {
        $rcount = $results.Count
        Write-Verbose "Found $rcount results"
        if ($parameterList.keys) {
            $searchkeys = $parameterList.keys.split()
        }

        foreach ($i in $searchkeys) {
            Write-Verbose "Working with key: $i"
            $parseTarget = $parameterList[$i]
            if ($parseTarget.ref) {
                $results = $results | where-object {$_.$i.ref -eq $parseTarget.ref}
                $rcount = $results.Count
                Write-Verbose "Searching for key $parseTarget as REF"
                Write-Verbose "Found $rcount results for key $i"
            } else {
                $results = $results | where-object {$_.$i -eq $parseTarget}
                $rcount = $results.Count
                Write-Verbose "Searching for key $parseTarget"
                Write-Verbose "Found $rcount results for key $i"
            }

        }
    }

    # Return the results of the call back to the cmdlet.
    foreach ($o in $results) {
        if ($o.id) {
            $o | Add-Member -MemberType NoteProperty -Name 'pipeId' -Value $o.id
        }
        if ($o.name) {
            $o | Add-Member -MemberType NoteProperty -Name 'pipeName' -Value $o.name
        }
    }
    if ($restContext.throttleCorrection.IsPresent) {
        Start-Sleep -Seconds 1
    }
    # empty POST/DELETE reply shouldnt leak a $null into the callers output
    if ($null -eq $results) {
        return
    }
    return $results
}
