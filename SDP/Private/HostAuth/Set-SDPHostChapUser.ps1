function Set-SDPHostChapUser {
    param(
        [parameter(Mandatory)]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $chapUser,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
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
        $endpoint = "hosts"
    }
    
    process {
        # Grab host
        $sdpHost = Get-SDPHost -name $hostName -k2context $k2context

        # Grab chap user
        $sdpChapuser = Get-SDPChapUser -name $chapUser -k2context $k2context

        # Create body
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name 'id' -Value $sdpHost.id 
        $o | Add-Member -MemberType NoteProperty -Name 'tid' -Value $sdpHost.name
        $o | Add-Member -MemberType NoteProperty -Name 'host_auth_profile' -Value $sdpChapuser.name

        $body = $o

        $endpointURI = $endpoint + '/' + $sdpHost.id

        $results = Invoke-SDPRestCall -endpoint $endpointURI -method PATCH -body $body -k2context $k2context 
        return $results
    }

}