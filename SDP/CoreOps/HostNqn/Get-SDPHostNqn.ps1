<#
    SDPHostNqn — typed wrapper for an NVMe Qualified Name assigned to a host.

    The API resource has no `name` field; it's identified by id. The
    `host` ref is preserved for Update-SDPRefObjects to attach a runtime
    `host_name` NoteProperty.
#>

class SDPHostNqn {

    # --- Properties shown in the default table view ---
    [string]   $id
    [string]   $nqn

    # --- Ref preserved for Update-SDPRefObjects ---
    [psobject] $host

    # Hidden context
    hidden [string] $k2context

    SDPHostNqn() {}

    SDPHostNqn([psobject] $apiHit, [string] $k2context) {
        $this.id        = $apiHit.id
        $this.nqn       = $apiHit.nqn
        $this.k2context = $k2context

        if ($apiHit.host) { $this.host = $apiHit.host }
    }

    # ---- Operational methods --------------------------------------------

    [SDPHostNqn] Refresh() {
        return [SDPHostNqn]::new(
            (Get-SDPHostNqn -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [void] Delete() {
        # Remove-SDPHostNqn currently keys off hostName, not id; resolve
        # via the host ref attached to this instance.
        $hostRef = $this.host
        if ($hostRef -and $hostRef.ref) {
            $hostId = ($hostRef.ref -split '/')[-1]
            $hostObj = Get-SDPHost -id $hostId -k2context $this.k2context -doNotResolve
            Remove-SDPHostNqn -hostName $hostObj.name -k2context $this.k2context | Out-Null
        }
    }

    [string] ToString() {
        return $this.nqn
    }
}

Update-TypeData -TypeName 'SDPHostNqn' `
                -DefaultDisplayPropertySet 'id','nqn','host_name' `
                -Force


<#
    .SYNOPSIS
    Returns a list of host NQNs

    .EXAMPLE
    Get-SDPHostNqn -hostName Host01

    .EXAMPLE
    Get-SDPHost | where-object {$_.name -like "TestDev*"} | Get-SDPHostNqn

    .DESCRIPTION
    Gets a list of all hosts and their NQNs. Can specify by host or NQN. Accepts piped input from Get-SDPHost

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPHostNqn {
    [CmdletBinding()]
    [OutputType([SDPHostNqn])]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [Alias('name')]
        [string] $hostName,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $nqn,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "host_nqns"
    }

    process {

        # Special Ops

        if ($hostName) {
            $hostObj = Get-SDPHost -name $hostName -k2context $k2context -doNotResolve
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject
            $PSBoundParameters.host = $hostPath
            $PSBoundParameters.remove('hostName') | Out-Null
        }

        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        # Query

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context

        $instances = foreach ($hit in $results) {
            [SDPHostNqn]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
