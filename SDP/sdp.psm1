  #Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$CoreOps = @( Get-ChildItem -Path $PSScriptRoot\CoreOps\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

$allpublic = @($Public + $CoreOps)

$num = 0
Foreach($import in @($allpublic + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
    $num++
}

Export-ModuleMember -Function $allpublic.Basename -alias * 

Write-Host "--- Loaded $num functions ---"