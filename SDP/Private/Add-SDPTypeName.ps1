<#
    Tags an object's PSTypeNames with a custom name so PowerShell's
    format engine can match a TableControl in SDP.format.ps1xml.

    Used by Get-SDP* cmdlets that don't have a backing class — the
    typename injection is what makes their output render as a table
    instead of falling through to the default >4-properties = list
    heuristic.

    Pattern in cmdlet code:

        $results = Invoke-SDPRestCall ... | Add-SDPTypeName -TypeName 'SDPxxx'

    The function streams; pass through pipeline. Idempotent: inserting
    the same typename twice is harmless (PowerShell tolerates duplicate
    PSTypeNames entries).
#>

function Add-SDPTypeName {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        $InputObject,
        [parameter(Mandatory)]
        [string] $TypeName
    )
    process {
        if ($null -ne $InputObject) {
            $InputObject.PSObject.TypeNames.Insert(0, $TypeName)
        }
        $InputObject
    }
}
