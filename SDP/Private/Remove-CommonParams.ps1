function Remove-CommonParams {
    param(
        [parameter(Mandatory)]
        [hashtable] $parameterList
    )

    if ($parameterList) {
        foreach ($p in [System.Management.Automation.PSCmdlet]::CommonParameters) {
            $parameterList.Remove($p)
        }
        $parameterList.Remove('k2context')
    }
    return $parameterList
}