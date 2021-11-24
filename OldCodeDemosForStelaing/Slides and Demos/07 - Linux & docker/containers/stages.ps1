Write-Debug "Running clean, build, test, run."

$olddbg = $DebugPreference; $oldvb = $VerbosePreference; $older = $ErrorActionPreference
$DebugPreference="Continue"; $VerbosePreference="SilentlyContinue"; $ErrorActionPreference="Stop"

.\stages\cleanup.ps1 | Out-Default
.\stages\setup.ps1 | Out-Default

.\stages\test.ps1 | Out-Default
.\stages\demo.ps1 | Out-Default

$DebugPreference = $olddbg;$VerbosePreference = $oldvb;$ErrorActionPreference = $older