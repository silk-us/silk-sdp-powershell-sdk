<#
    .SYNOPSIS
    Gather the requested event information.

    .EXAMPLE
    Get-SDPEvents -EventId 28

    This will return all DELETE_VOLUME operations and their corresponding event information. 
            
    .NOTES
    Authored by J.R. Phillips (GitHub: JayAreP)

    .LINK
    https://github.com/silk-us/silk-sdp-powershell-sdk
#>

class sdpevent {
    [string] $event_id
    [string] $id
    [string] $labels
    [string] $level 
    [string] $message
    [string] $name
    [datetime] $timestamp 
    [string] $user
    [string] $pipeId
    [string] $pipeName
}

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
        [datetime] $after,
        [parameter()]
        [string] $user,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    begin {
        $endpoint = 'events'
    }
    

    # function specific operations
    process {
        if ($after) {
            $cdate = Convert-SDPTimeStampTo -timestamp $after -int
            $PSBoundParameters.remove('after') | Out-Null
            $PSBoundParameters.timestamp = $cdate
        }
        
        $results = Invoke-SDPRestCall -endpoint $endpoint -method GET -parameterList $PSBoundParameters -k2context $k2context -strictURI -strictURIgte timestamp

        $eventArray = @()

        foreach ($i in $results) {
            # Object
            # Build an instance of the class
            $classSDPEvent = [sdpevent]::new()

            # Populate the class object
            $classSDPEvent.event_id = $i.event_id
            $classSDPEvent.id = $i.id
            $classSDPEvent.labels = $i.labels
            $classSDPEvent.level = $i.level
            $classSDPEvent.message = $i.message
            $classSDPEvent.name = $i.name
            $classTimeStamp = Convert-SDPTimeStampFrom -timestamp $i.timestamp
            $classSDPEvent.timestamp = $classTimeStamp
            $classSDPEvent.user = $i.user
            $classSDPEvent.pipeId = $i.pipeId
            $classSDPEvent.pipeName = $i.pipeName

            $eventArray += $classSDPEvent
        }

        return $eventArray
    }
}

