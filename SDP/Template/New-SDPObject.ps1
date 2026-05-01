function CMDLETNAME {
    [CmdletBinding()]
    param(
        [parameter()]
        [string] $k2context = 'k2rfconnection'
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
            Invoke-SDPRestCall -endpoint $endpoint -method POST -body $body -k2context $k2context -ErrorAction SilentlyContinue
        } catch {
            return $Error[0]
        }

        $results = Wait-SDPObject -Activity $name -Get {
            Get-SDPOBJECT -name $name -k2context $k2context
        }

        return $results
    }
}
