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
    hidden [string] $context

    SDPHostNqn() {}

    SDPHostNqn([psobject] $apiHit, [string] $context) {
        $this.id        = $apiHit.id
        $this.nqn       = $apiHit.nqn
        $this.context = $context

        if ($apiHit.host) { $this.host = $apiHit.host }
    }

    # ---- Operational methods --------------------------------------------

    [SDPHostNqn] Refresh() {
        return [SDPHostNqn]::new(
            (Get-SDPHostNqn -id $this.id -context $this.context -doNotResolve),
            $this.context)
    }

    [void] Delete() {
        # Remove-SDPHostNqn currently keys off hostName, not id; resolve
        # via the host ref attached to this instance.
        $hostRef = $this.host
        if ($hostRef -and $hostRef.ref) {
            $hostId = ($hostRef.ref -split '/')[-1]
            $hostObj = Get-SDPHost -id $hostId -context $this.context -doNotResolve
            Remove-SDPHostNqn -hostName $hostObj.name -context $this.context | Out-Null
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
        [string] $context = "sdpconnection"
    )

    begin {
        $endpoint = "host_nqns"
    }

    process {

        # Special Ops

        if ($hostName) {
            $hostObj = Get-SDPHost -name $hostName -context $context -doNotResolve
            $hostPath = ConvertTo-SDPObjectPrefix -ObjectPath "hosts" -ObjectID $hostObj.id -nestedObject
            $PSBoundParameters.host = $hostPath
            $PSBoundParameters.remove('hostName') | Out-Null
        }

        $PSBoundParameters.Remove('doNotResolve') | Out-Null

        # Query

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -context $context -strictURI

        $instances = foreach ($hit in $results) {
            [SDPHostNqn]::new($hit, $context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -context $context
        }
    }
}
