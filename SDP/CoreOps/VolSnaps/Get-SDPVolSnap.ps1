<#
    .SYNOPSIS
    Retrieves volume snapshot information from the SDP.

    .DESCRIPTION
    Queries for volume snapshots (VolSnaps) on the Silk Data Pod. VolSnaps represent the relationship between volumes and snapshots.

    .PARAMETER sourceId
    Filter by the source snapshot ID. Accepts piped input from snapshot objects.

    .PARAMETER id
    The unique identifier of the volsnap.

    .PARAMETER name
    The name of the volsnap to retrieve.

    .PARAMETER k2context
    Specifies the K2 context to use for authentication. Defaults to 'k2rfconnection'.

    .EXAMPLE
    Get-SDPVolSnap
    Retrieves all volume snapshots from the SDP.

    .EXAMPLE
    Get-SDPVolSnap -name "VolSnap01"
    Retrieves the volume snapshot named "VolSnap01".

    .EXAMPLE
    Get-SDPVolSnap -sourceId 123
    Retrieves all volume snapshots for a specific source snapshot.

    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>
function Get-SDPVolSnap {
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $sourceId,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $name,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

    begin {
        $endpoint = "volsnaps"
    }

    process {

        # Query 

        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -k2context $k2context

        # Special Ops

        if ($sourceId) {
            $sourceObject = ConvertTo-SDPObjectPrefix -ObjectID $sourceId -ObjectPath "snapshots" -compact
            $results = $results | Where-Object {$_.snapshot -match $sourceObject}
        }

        return $results
    }
}
