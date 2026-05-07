function Remove-SDPVgCapacityPolicy {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        # Typed as [object] to dodge module load-order coupling on the
        # SDPVgCapacityPolicy class. Validated at the top of process.
        [parameter(ValueFromPipeline)]
        [object] $InputObject,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('pipeId')]
        [string] $id,
        [parameter()]
        [switch] $Force,
        [parameter()]
        [string] $k2context = 'k2rfconnection'
    )

    ## Special Ops
    begin {
        $endpoint = "vg_capacity_policies"
    }

    process {
        if ($InputObject -and $InputObject -isnot [SDPVgCapacityPolicy]) {
            throw "Remove-SDPVgCapacityPolicy accepts pipeline input only from SDPVgCapacityPolicy; got [$($InputObject.GetType().FullName)]."
        }
        if ($InputObject) {
            $id = $InputObject.id
            if (-not $PSBoundParameters.ContainsKey('k2context')) {
                $k2context = $InputObject.k2context
            }
        }

        ## Make the call
        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
        if ($PSCmdlet.ShouldProcess("SDPVgCapacityPolicy id=$id", 'Remove')) {
            $endpointURI = $endpoint + '/' + $id
            $results = Invoke-SDPRestCall -endpoint $endpointURI -method DELETE -k2context $k2context
            return $results
        }
    }
}