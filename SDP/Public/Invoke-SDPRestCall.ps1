<#
    .SYNOPSIS 
    Custom rest call for Kaminario K2 platform 

    .EXAMPLE
    (after logging into a K2)
    Invoke-SDPRestCall -endpoint volume_groups -method GET
    This will return the .hits return for the https://{k2Server}/api/v2/volume_groups API endpoint using the method GET.

    .EXAMPLE
    Invoke-SDPRestCall -endpoint volume -method PATCH -body $body -k2context TestDev
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
        [string] $k2context = 'k2rfconnection',
        [parameter()]
        [int] $limit = 9999,
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

    # Construct the base URI. New-SDPURI returns a value ending in '?';
    # strip it so we have a clean endpoint and can decide later whether
    # to append a query string (legacy path) or pass query params via
    # -Body to Invoke-RestMethod (strictURI path).

    $endpointURI = (New-SDPURI -endpoint $endpoint -k2context $k2context).TrimEnd('?')

    # Strip CommonParameters and k2context from the parameter list so we
    # only walk user-supplied filters.

    if ($parameterList) {
        foreach ($p in [System.Management.Automation.PSCmdlet]::CommonParameters) {
            $parameterList.Remove($p) | Out-Null
        }
        $parameterList.Remove('k2context') | Out-Null
    }

    # Decide how to deliver query parameters.
    #
    # strictURI + GET: build a hashtable of operator-suffixed keys
    # (name__in, id__gt, etc.) and pass it via -Body to Invoke-RestMethod.
    # On a GET, Invoke-RestMethod auto-serializes a hashtable body to a
    # URL-encoded query string - cleaner than the manual concatenation
    # we used to do, and properly URL-encoded for free.
    #
    # Everything else (legacy GET, POST/PATCH/DELETE): keep the URL plain
    # and append __limit the old way for compatibility with cmdlets that
    # haven't been migrated to strictURI yet. They'll still post-fetch
    # filter client-side below.

    $queryParams = $null

    if ($strictURI -and $method -eq 'GET') {
        $queryParams = @{}
        if (-not $noLimit) { $queryParams.Add('__limit', $limit) }

        if ($parameterList -and $parameterList.Count -gt 0) {
            Write-Verbose "-- REST (strictURI) using parameters --"
            $parameterList | ConvertTo-Json -Depth 10 | Write-Verbose

            foreach ($p in $parameterList.Keys) {
                $value = $parameterList[$p]
                if ($value.ref) {
                    Write-Verbose "$p declared as REF; skipping URI"
                    continue
                }
                if ($value -is [int]) {
                    if ($strictURIgte -contains $p) {
                        $queryParams.Add("${p}__gt", $value)
                    } elseif ($strictURIlte -contains $p) {
                        $queryParams.Add("${p}__lt", $value)
                    } else {
                        $queryParams.Add("${p}__in", $value)
                    }
                } elseif ($value -is [bool]) {
                    $queryParams.Add($p, $value)
                } else {
                    # Strings: __in is the new default. -strictString is retained
                    # for back-compat but is now a no-op since __in == bare equality
                    # for a single scalar value.
                    $queryParams.Add("${p}__in", $value)
                }
            }
            Write-Verbose "-- REST (strictURI) using keylist --"
            $queryParams | ConvertTo-Json -Depth 10 | Write-Verbose
        }
    } else {
        # Legacy path: append __limit to URL for non-migrated cmdlets.
        if ($method -eq 'GET' -and -not $noLimit) {
            $endpointURI = $endpointURI + '?__limit=' + $limit
        }
        $endpointURI = New-URLEncode -URL $endpointURI -k2context $k2context

        if ($parameterList -and $parameterList.Count -gt 0) {
            Write-Verbose "-- REST using parameters (post-fetch filter) --"
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

    $restContext = Get-Variable -Scope Global -Name $k2context -ValueOnly -ErrorAction SilentlyContinue
    if (-not $restContext) {
        Write-Error "No SDP session found for context '$k2context'. Run 'Connect-SDP' (or pass -k2context <name> if you connected with a custom context name)." -Category AuthenticationError
        return
    }

    # Make the call.
    #
    # Two failure modes need disambiguation in the catch:
    #   1. HTTP 2xx with empty body and Content-Type: application/json. Invoke-
    #      RestMethod's deserializer throws on empty-body JSON. The operation
    #      actually succeeded; we should swallow the throw and return $null.
    #   2. HTTP 4xx/5xx, with or without a body. The operation actually failed
    #      and the caller needs to know - even when the server didn't bother
    #      to include a JSON error_msg.
    # The resolver inspects $_.Exception.Response.StatusCode to tell them apart.

    $resolveRestException = {
        param($errorRecord)

        $statusCode = $null
        if ($errorRecord.Exception.Response) {
            try { $statusCode = [int]$errorRecord.Exception.Response.StatusCode } catch { }
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
                if ($parsed.error_msg) { $msg = $parsed.error_msg } else { $msg = $detailMsg }
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

    if ($PSVersionTable.PSEdition -eq 'Core') {
        if ($body) {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -body $bodyjson -ContentType 'application/json' -Credential $restContext.credentials -SkipCertificateCheck -TimeoutSec $timeOut
            } catch {
                if (& $resolveRestException $_) { $results = $null } else { return }
            }
        } elseif ($queryParams) {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -body $queryParams -Credential $restContext.credentials -SkipCertificateCheck -TimeoutSec $timeOut
            } catch {
                if (& $resolveRestException $_) { $results = $null } else { return }
            }
        } else {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -Credential $restContext.credentials -SkipCertificateCheck -TimeoutSec $timeOut
            } catch {
                if (& $resolveRestException $_) { $results = $null } else { return }
            }
        }
    } elseif ($PSVersionTable.PSEdition -eq 'Desktop') {
        if ([System.Net.ServicePointManager]::CertificatePolicy -notlike 'TrustAllCertsPolicy') {
            Write-Verbose "Correcting certificate policy"
            Unblock-CertificatePolicy
        }
        if ([Net.ServicePointManager]::SecurityProtocol -notmatch 'Tls12') {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol + 'Tls12'
        }
        if ($body) {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -body $bodyjson -ContentType 'application/json' -Credential $restContext.credentials -TimeoutSec $timeOut
            } catch {
                if (& $resolveRestException $_) { $results = $null } else { return }
            }
        } elseif ($queryParams) {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -body $queryParams -Credential $restContext.credentials -TimeoutSec $timeOut
            } catch {
                if (& $resolveRestException $_) { $results = $null } else { return }
            }
        } else {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -Credential $restContext.credentials -TimeoutSec $timeOut
            } catch {
                if (& $resolveRestException $_) { $results = $null } else { return }
            }
        }
    }

    <#
        Due to how the API accepts arguments, I often need to capture all results and filter for the desired objects after-the-fact.
        If this looks inefficient, it's because it is. Thankfully there's not a lot of metadata presented through these queries, 
        so the operational impact is minimal. 
    #>
    if ($fullResponse) {
        return $results
    } else {
        $results = $results.hits
    }
    
    if ($parameterList.Count -gt 0 -and $strictURI -eq $false) {
        $rcount = $results.Count
        Write-Verbose "Found $rcount results"
        if ($parameterList.keys) {
            $searchkeys = $parameterList.keys.split()
        }
    
        foreach ($i in $searchkeys) {
            Write-Verbose "Working with key: $i"
            $parseTarget = $parameterList[$i]
            # return $parseTarget
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
    return $results
}
