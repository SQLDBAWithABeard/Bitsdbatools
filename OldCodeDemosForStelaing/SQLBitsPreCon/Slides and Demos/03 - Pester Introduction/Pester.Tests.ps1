Describe "These tests have a Backup Tag" -Tag Backup {
    Context "Checking SQL can access Backup Location" {
        It "ROB-XPS should be able to access C:\MSSQL\Backups" {
            Test-DbaSqlPath -SqlInstance ROB-XPS -Path C:\MSSQL\BACKUP | Should -Be True
        }
    }
    Context "Checking Backup Jobs have run successfully" {
        @(Get-DbaAgentJob -SqlInstance ROB-XPS).Where{$_.Name -like '*DatabaseBackup*'}.ForEach{
            It "ROB-XPS Backup Job $($PSItem.Name) should have run successfully" {
                $PSItem.LastRunOutCome | Should -Be 'Succeeded'
            }
        }
    }
}
Describe "These tests have an Identity Tag" -Tag Identity {
    @(Test-DbaIdentityUsage -SqlInstance ROB-XPS, ROB-XPS,ROB-XPS).ForEach{
        if ($psitem.Database -ne 'tempdb') {
            $columnfqdn = "$($psitem.Database).$($psitem.Schema).$($psitem.Table).$($psitem.Column)"
            It "usage for $columnfqdn on $($psitem.SqlInstance) should be less than 30 percent" {
                $psitem.PercentUsed | Should -BeLessThan 90
            }
        }
    }
}