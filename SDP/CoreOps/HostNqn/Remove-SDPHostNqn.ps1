<#
    .SYNOPSIS
    Remove an existing host Nqn.

    .EXAMPLE
    Remove-SDPHostNqn -hostName Host01

    .EXAMPLE
    Get-SDPHostNqn -hostName LinuxHost03 | Remove-SDPHostNqn

    .DESCRIPTION
    Use this function to remove an existing host Nqn using these examples. Accepts piped imput from Get-SDPHostNqn

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Remove-SDPHostNqn {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = 'host_nqns'
    }

    process {

        # Special Ops — locate the NQN record by host.

        $hostNqn = Get-SDPHostNqn -hostName $hostName -context $context -doNotResolve

        # Call

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPHostNqn hostName=$hostName id=$($hostNqn.id)", 'Remove')) {
            $results = Invoke-SDPRestCall -endpoint "$endpoint/$($hostNqn.id)" -method DELETE -context $context
            return $results
        }
    }
}
