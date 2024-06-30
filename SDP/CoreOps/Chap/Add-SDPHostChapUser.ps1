function Add-SDPHostChapUser {
    param(
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [Alias('pipeName')]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $chapUserName,
        [parameter()]
        [string] $k2context = "k2rfconnection"
    )

        <#
        .SYNOPSIS
        Assigns a CHAP user to a host. 

        .EXAMPLE 
        Add-SDPHostChapUser -hostName Host01 -chapUserName ChapUser01

        .EXAMPLE 
        Get-SDPHost -name Host01 | Add-SDPHostChapUser -chapUserName ChapUser01

        .DESCRIPTION
        Sets the Chap User for any host. Accepts piped input from Get-SDPHost. 

        .NOTES
        Authored by J.R. Phillips (GitHub: JayAreP)

        .LINK
        https://www.github.com/JayAreP/K2RF/

    #>
    begin {
        $endpoint = 'hosts'
    }

    process{
        ## Special Ops

        $hostObj = Get-SDPHost -name $hostName -k2context $k2context
        $chapUserObj = Get-SDPChapUser -name $chapUserName -k2context $k2context

        
        # Build the Object
        $o = New-Object psobject
        $o | Add-Member -MemberType NoteProperty -Name "map_auth_profiles_names" -Value $chapUserObj.name
        
        $body = $o

        $endpoint = $endpoint + '/' + $hostObj.id
        ## Make the call
        $results = Invoke-SDPRestCall -endpoint $endpoint -method PATCH -body $body -k2context $k2context 
        return $results
    }

}