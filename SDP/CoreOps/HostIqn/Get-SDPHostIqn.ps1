<#
    SDPHostIqn — typed wrapper for an iSCSI Qualified Name assigned to a host.

    The API resource has no `name` field; it's identified by id. The
    `host` ref is preserved for Update-SDPRefObjects to attach a runtime
    `host_name` NoteProperty.
#>

class SDPHostIqn {

    # --- Properties shown in the default table view ---
    [string]   $id
    [string]   $iqn

    # --- Ref preserved for Update-SDPRefObjects ---
    [psobject] $host

    # Hidden context
    hidden [string] $k2context

    SDPHostIqn() {}

    SDPHostIqn([psobject] $apiHit, [string] $k2context) {
        $this.id        = $apiHit.id
        $this.iqn       = $apiHit.iqn
        $this.k2context = $k2context

        if ($apiHit.host) { $this.host = $apiHit.host }
    }

    # ---- Operational methods --------------------------------------------

    [SDPHostIqn] Refresh() {
        return [SDPHostIqn]::new(
            (Get-SDPHostIqn -id $this.id -k2context $this.k2context -doNotResolve),
            $this.k2context)
    }

    [void] Delete() {
        # Remove-SDPHostIqn currently keys off hostName, not id; resolve
        # via the host ref attached to this instance.
        $hostRef = $this.host
        if ($hostRef -and $hostRef.ref) {
            $hostId = ($hostRef.ref -split '/')[-1]
            $hostObj = Get-SDPHost -id $hostId -k2context $this.k2context -doNotResolve
            Remove-SDPHostIqn -hostName $hostObj.name -k2context $this.k2context | Out-Null
        }
    }

    [string] ToString() {
        return $this.iqn
    }
}

Update-TypeData -TypeName 'SDPHostIqn' `
                -DefaultDisplayPropertySet 'id','iqn','host_name' `
                -Force


<#
    .SYNOPSIS
    Returns a list of host IQNs

    .EXAMPLE
    Get-SDPHostIqn -hostName Host01

    .EXAMPLE
    Get-SDPHost | where-object {$_.name -like "TestDev*"} | Get-SDPHostIqn

    .DESCRIPTION
    Gets a list of all hosts and their IQNs. Can specify by host or IQN. Accepts piped input from Get-SDPHost

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Get-SDPHostIqn {
    [CmdletBinding()]
    [OutputType([SDPHostIqn])]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [Alias('name')]
        [string] $hostName,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $iqn,
        [parameter()]
        [switch] $doNotResolve,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "host_iqns"
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
            [SDPHostIqn]::new($hit, $k2context)
        }

        if ($doNotResolve) {
            $instances
        } else {
            $instances | Update-SDPRefObjects -k2context $k2context
        }
    }
}
