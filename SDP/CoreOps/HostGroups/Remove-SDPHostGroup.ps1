<#
    .SYNOPSIS
    Removes any existing Host Group.

    .EXAMPLE
    Remove-SDPHostGroup -name HostGroup01

    .EXAMPLE
    Get-SDPHostGroup | where {$_.name -like "LinuxHosts*"} | Remove-SDPHostGroup

    .DESCRIPTION
    Use this function to remove any existing Host Group. This command accepts piped input from a Get-SDPHostGroup query.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPHostGroup {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        # Typed as [object] to dodge module load-order coupling on the
        # SDPHostGroup class. Validated to [SDPHostGroup] at the top of process.
        [parameter(ValueFromPipeline)]
        [object] $InputObject,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'host_groups'
    }

    process {

        if ($InputObject -and $InputObject -isnot [SDPHostGroup]) {
            throw "Remove-SDPHostGroup accepts pipeline input only from SDPHostGroup; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $id = $InputObject.id
            if (-not $PSBoundParameters.ContainsKey('k2context')) {
                $k2context = $InputObject.k2context
            }
        }

        # Special Ops — resolve name to id when no id was passed.

        if ($name -and !$id) {
            $hostGroup = Get-SDPHostGroup -name $name -k2context $k2context -doNotResolve
            $id = $hostGroup.id
        }

        # Call

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPHostGroup id=$id", 'Remove')) {
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$id" -method DELETE -k2context $k2context
            return $results
        }
    }
}
