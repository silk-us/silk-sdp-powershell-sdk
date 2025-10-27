<#
.SYNOPSIS
    Creates a basic auth header from a PS credential object to use with REST API calls. 

.EXAMPLE
    $creds = Get-Credential
    $header = New-APIHeader -Credential $creds
    Invoke-RestMethod -Method GET -uri https://10.10.10.10/api/v1/sla_domain -Headers $header
#>

function New-SDPAPIHeader {
    param(
        [parameter(mandatory)]
        [System.Management.Automation.PSCredential]$Credential
    )


    $username = $Credential.username
    $password = $Credential.GetNetworkCredential().password
    @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username+":"+$password ))}
}
