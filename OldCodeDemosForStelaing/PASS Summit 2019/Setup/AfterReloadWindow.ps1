if ($Env:COMPUTERNAME -eq 'BEARDXPS') {
    # Rob
    Set-Location 'GIT:\PASS Summit 2019'
}elseif ($Env:COMPUTERNAME -like '*labmachine*' -or $Env:COMPUTERNAME -eq 'DESKTOP-V8G9S2O') {
    Set-Location 'GIT:\PASS Summit 2019'
}else {
    Write-Warning "Whose machine are you using folks?"
    break
}

    #region load variables
    . .\Setup\vars.ps1
    #endregion

    $ShowAzure = $false
$ShowGit = $false
$Error.Clear()
$PSDefaultParameterValues += @{
    "*dba*:SqlCredential" = $cred
}
Clear-Host