<#
    SDPHostPwwn — typed wrapper for an FC port (PWWN) attached to a
    host. Endpoint is /api/v2/host_fc_ports.

    `host` is the only ref-shaped property; Update-SDPRefObjects attaches
    `host_name` at runtime.
#>

class SDPHostPwwn {

    # --- Properties shown in the default table view ---
    [string]   $id
    [string]   $pwwn

    # --- Refs preserved for Update-SDPRefObjects to walk. ---
    [psobject] $host

    # Hidden context
    hidden [string] $k2context

    SDPHostPwwn() {}

    SDPHostPwwn([psobject] $apiHit, [string] $k2context) {
        $this.id        = $apiHit.id
        $this.pwwn      = $apiHit.pwwn
        $this.k2context = $k2context

        if ($apiHit.host) { $this.host = $apiHit.host }
    }

    # ---- Operational methods --------------------------------------------

    [SDPHostPwwn] Refresh() {
        return [SDPHostPwwn]::new(
            (Get-SDPHostPwwn -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [void] Delete() {
        Remove-SDPHostPwwn -id $this.id -k2context $this.k2context | Out-Null
    }

    [string] ToString() {
        return $this.pwwn
    }
}

Update-TypeData -TypeName 'SDPHostPwwn' `
                -DefaultDisplayPropertySet 'id','pwwn','host_name' `
                -Force


<#
    .SYNOPSIS
    Returns a list of host PWWNs (FC ports).

    .DESCRIPTION
    Queries the /host_fc_ports endpoint. Filter by host or by PWWN
    string. Accepts piped input from Get-SDPHost.

    .PARAMETER hostName
    Filter by host name.

    .PARAMETER id
    The unique identifier of the PWWN record.

    .PARAMETER pwwn
    Filter by PWWN string.

    .PARAMETER doNotResolve
    Skip the auto-pipe through Update-SDPRefObjects. Returns raw API
    objects.

    .PARAMETER k2context
    K2 context name. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPHostPwwn -hostName Host01

    .EXAMPLE
    Get-SDPHost | where-object {$_.name -like "TestDev*"} | Get-SDPHostPwwn

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPHostPwwn {
    [CmdletBinding()]
    [OutputType([SDPHostPwwn])]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [Alias('name')]
        [string] $hostName,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $pwwn,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = 'host_fc_ports'
    }

    process {

        # Special Ops — translate hostName to a host ref.

        if ($hostName) {
            $hostObj = Get-SDPHost -name $hostName -k2context $k2context -doNotResolve
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject
            $PSBoundParameters.host = $hostPath
            $PSBoundParameters.remove('hostName') | Out-Null
        }

        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        $instances = foreach ($hit in $results) {
            [SDPHostPwwn]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
