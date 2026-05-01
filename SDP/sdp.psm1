# Get public, coreops, and private function definition files.
# Class definitions live co-located with their owning Get-SDP* cmdlet
# inside CoreOps/, so no separate Classes folder is needed.
#
# Format definitions live in SDP.format.ps1xml at the module root and
# are loaded by PowerShell's module loader via FormatsToProcess in
# sdp.psd1. The per-class .format.ps1xml files in CoreOps/*/ are kept
# for reference / editing convenience but are NOT loaded — edits there
# have no effect. To change a default view, edit SDP.format.ps1xml.

$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$CoreOps = @( Get-ChildItem -Path $PSScriptRoot\CoreOps\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

$allpublic = @($Public + $CoreOps)

$num = 0
foreach ($import in @($allpublic + $Private)) {
    try {
        . $import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
    $num++
}

Export-ModuleMember -Function $allpublic.BaseName -Alias *

Write-Verbose "--- Loaded $num functions ---" -Verbose

Write-Verbose "--- the v2.x release of the SDP Powershell SDK contains numerous changes that can break existing scripts written with v1.x ---" -Verbose
Write-Verbose "--- Please review the release notes and update your scripts accordingly. ---" -Verbose
