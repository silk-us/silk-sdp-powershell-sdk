<#
    .SYNOPSIS
    Polls a Get-SDP* call until it returns a result or a timeout elapses.

    .DESCRIPTION
    Wraps the "POST then GET-until-visible" pattern that most New-SDP* cmdlets
    need because the SDP API returns nothing on POST success and the new
    object is queued internally before it shows up on a GET.

    Pass a script block that performs the GET. The helper invokes it on an
    interval until it returns a truthy value, or until the timeout elapses.
    On timeout it writes a non-terminating error.

    .PARAMETER Get
    A script block that performs the lookup. The first truthy return value
    becomes the helper's return value.

    .PARAMETER TimeoutSec
    Maximum number of seconds to wait. Default 60.

    .PARAMETER PollIntervalSec
    Seconds to sleep between polls. Default 1.

    .PARAMETER Activity
    Optional label used in verbose output to identify what's being waited
    on (e.g. the volume name). Cosmetic only.

    .EXAMPLE
    Wait-SDPObject -Get { Get-SDPVolume -name $name -k2context $k2context } -Activity $name

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

function Wait-SDPObject {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [scriptblock] $Get,
        [parameter()]
        [int] $TimeoutSec = 60,
        [parameter()]
        [int] $PollIntervalSec = 1,
        [parameter()]
        [string] $Activity
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    $label = if ($Activity) { " ($Activity)" } else { '' }

    do {
        $result = & $Get
        if ($result) {
            return $result
        }
        Write-Verbose " --> Waiting on SDP object$label"
        Start-Sleep -Seconds $PollIntervalSec
    } while ((Get-Date) -lt $deadline)

    Write-Error "Timed out after $TimeoutSec seconds waiting for SDP object$label."
}
