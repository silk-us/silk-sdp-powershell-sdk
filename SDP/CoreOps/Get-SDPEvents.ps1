function Get-SDPEvents {
    param(
        [parameter()]
        [Alias("EventId")]
        [int] $event_id,
        [parameter()]
        [int] $id,
        [parameter()]
        [string] $labels,
        [parameter()]
        [string] $level,
        [parameter()]
        [string] $message,
        [parameter()]
        [string] $name,
        [parameter()]
        [datetime] $timestamp,
        [parameter()]
        [string] $user,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    <#
        .SYNOPSIS
        Gather the requested event information.

        .EXAMPLE
        Get-SDPEvents -EventId 28

        This will return all DELETE_VOLUME operations and their corresponding event information. 
                
        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/
    #>
    begin {
        $endpoint = 'events'
    }
    

    # function specific operations
    process {
        if ($timestamp) {
            $cdate = Convert-SDPTimeStampTo -timestamp $timestamp
            $PSBoundParameters.remove('timestamp') | Out-Null
            $PSBoundParameters.timestamp = $cdate
        }
        
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI
        return $results
    }
}

