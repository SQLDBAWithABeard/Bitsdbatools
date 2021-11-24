## Use a configuration file

Get-Content 'Git:\PSConfAsiaPreCon\Slides and Demos\08 - Pester\TestConfig.json'

cd GIT:\dbatools-scripts-stuttgart
$Config = (Get-Content Get-Content 'Git:\PSConfAsiaPreCon\Slides and Demos\08 - Pester\TestConfig.json') -join "`n" | ConvertFrom-Json
Invoke-Pester -Show Fails