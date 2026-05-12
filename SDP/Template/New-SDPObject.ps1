function CMDLETNAME {
    [CmdletBinding()]
    param(
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    begin {
        $endpoint = ENDPOINTNAME
    }

    process {

        # Special Ops

        # Build the request body

        $body = New-Object psobject
        if ($name) {
            $body | Add-Member -MemberType NoteProperty -Name "name" -Value $name
        }
        if ($size) {
            $body | Add-Member -MemberType NoteProperty -Name "size" -Value $size
        }

        # Call — POST returns nothing on success; poll until the new object
        # appears via its Get-SDP* equivalent.

        try {
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -context $context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $name -Get {
            Get-SDPOBJECT -name $name -context $context
        }

        return $results
    }
}
