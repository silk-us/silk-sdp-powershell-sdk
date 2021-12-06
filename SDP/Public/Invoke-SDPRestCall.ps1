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
        [switch] $fullResponse
    )

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

    # Delcare the serviced API endpoint.

    $endpointURI = New-SDPURI -endpoint $endpoint -k2context $k2context
    if ($method -eq 'GET') {
        if (!$noLimit) {
            $limitURI = '__limit=' + $limit.ToString() + '&'
            $endpointURI = $endpointURI + $limitURI
        }
    }

    # Cleanup the parameter list and construct the URI with the argued parameters. (This removes system parameters, such as 'Verbose' and 'ErrorAction')

    if ($parameterList) {
        foreach ($p in [System.Management.Automation.PSCmdlet]::CommonParameters) {
            $parameterList.Remove($p)
        }
        $parameterList.Remove('k2context')
    }

    if ($parameterList.Count -gt 0) {
        Write-Verbose "-- REST Using following parameters --"
        $parameterList | ConvertTo-Json -Depth 10 | write-verbose
        if ($strictURI) {
            $searchkeys = $parameterList.keys.split()
            foreach ($p in $searchkeys) {
                Write-Verbose "Working with key: $p"
                $parseTarget = $parameterList[$p]
                if ($parseTarget.ref) {
                    Write-Verbose "$p is declares as REF... skipping URI"
                } else {
                    if ($parseTarget -is [int]) {
                        if ($strictURIgte -contains $p) {
                            $endpointURI = $endpointURI + $p + '__gt='+$parseTarget + '&'
                        } elseif ($strictURIlte -contains $p) {
                            $endpointURI = $endpointURI + $p + '__lt='+$parseTarget + '&'
                        } else {
                            $endpointURI = $endpointURI + $p + '__in='+$parseTarget + '&'
                        }
                    } elseif ($parseTarget -is [bool]) {
                        $endpointURI = $endpointURI + $p + '='+$parseTarget + '&'
                    } else {
                        if ($strictString) {
                            $endpointURI = $endpointURI + $p + '='+$parseTarget + '&'
                        } else {
                            $endpointURI = $endpointURI + $p + '__contains='+$parseTarget + '&'
                        }
                    }
                }
            }
        }
    }

    # Clean up the final URI.

    $endpointURI = $endpointURI.Substring(0,$endpointURI.Length-1)
    $endpointURI = New-URLEncode -URL $endpointURI -k2context $k2context

    Write-Verbose "Invoke-SDPRestCall --> Requesting $method from $endpointURI <--- Final URI"
    if ($body) {
        $bodyjson = $body | ConvertTo-Json -Depth 10
        Write-Verbose "-- REST Using following JSON body --"
        Write-Verbose $bodyjson
    }

    # declare the requested context's credential information 

    $restContext = Get-Variable -Scope Global -Name $k2context -ValueOnly

    # Make the call. 

    if ($PSVersionTable.PSEdition -eq 'Core') {
        if ($body) {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -Body $bodyjson -Credential $restContext.credentials -SkipCertificateCheck -ContentType 'application/json' 
            } catch {
                $return = (($_.ErrorDetails.Message | ConvertFrom-Json).error_msg)
                return $return | Write-Error
            }
        } else {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -Credential $restContext.credentials -SkipCertificateCheck
            } catch {
                $return = (($_.ErrorDetails.Message | ConvertFrom-Json).error_msg)
                return $return | Write-Error
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
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -Body $bodyjson -Credential $restContext.credentials -ContentType 'application/json' 
            } catch {
                $return = (($_.ErrorDetails.Message | ConvertFrom-Json).error_msg)
                return $return | Write-Error
            }
        } else {
            try {
                $results = Invoke-RestMethod -Method $method -Uri $endpointURI -Credential $restContext.credentials 
            } catch {
                $return = (($_.ErrorDetails.Message | ConvertFrom-Json).error_msg)
                return $return | Write-Error
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
    return $results
}
