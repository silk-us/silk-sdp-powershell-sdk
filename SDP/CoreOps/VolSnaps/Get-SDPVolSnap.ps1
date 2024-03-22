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
    <#
        .SYNOPSIS

        .EXAMPLE 

        .DESCRIPTION

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>

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
