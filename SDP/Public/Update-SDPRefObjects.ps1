function Update-SDPRefObjects {
    param(
        [parameter(ValueFromPipeline)]
        [psobject] $object
    )

    begin {
        $pathFunction = Build-SDPPathFunctions
        Write-Verbose "-- Invoke-SDPRestCall --> Update-SDPRefObjects -> "
    }

    Process {
        $allprops = $object.PSObject.Properties 
        $proptable = foreach ($i in $allprops) {
            $i | Select-Object name,TypeNameOfValue
        }
        foreach ($i in $proptable) {
            # check for 'ref' statement
            $prop = $i.name

            # if ref statement, grab path and id
            if ($object.$prop.ref) {
                Write-Verbose "--> Found ref for property $prop"
                # grab query function from $pathFunction table, acquire name
                $objectDetails = ConvertFrom-SDPObjectPrefix -Object $object.$prop
                $queryFunction = $pathFunction[$objectDetails.ObjectPath]
                $queryObjectID = $objectDetails.ObjectId
                $queryRequest = $queryFunction + " -id " + $queryObjectID
                $objectName = (Invoke-Expression $queryRequest).name

                # add _name to the ref property and include the above name, append it to the $object and return
                $propertyName = $prop + '_name'
                $object | Add-Member -MemberType NoteProperty -Name $propertyName -Value $objectName
            }

        }

        return $object 
    }
}