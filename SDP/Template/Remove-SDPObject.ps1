function CMDLETNAME {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $context = 'sdpconnection'
    )

    ## Special Ops
    begin {
        $endpoint = ENDPOINTNAME
    }

    process {
        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("CLASSNAME id=$id", 'Remove')) {
            ## Make the call
            $endpointURI = $endpoint + '/' + $id
            $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -context $context
            return $results
        }
    }
}