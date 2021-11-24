Describe "Advanced Admin tests" {
    Context "Query Store" {
    It " Should have default settings fro DemoDBBAreports" {
        $results = Get-DbaDbQueryStoreOptions -SqlInstance $Instance3 -Database Database
        $results.ActualState | Should Be 'Off'
        $results.DataFlushIntervalInSeconds | Should Be 900
        $results.StatisticsCollectionIntervalInMinutes | Should Be 60
        $results.MaxStorageSizeInMB | Should Be 100
        $results.QueryCaptureMode | SHould Be 'All'
    }}
    Context "logins"{
        It "Should not have RobsMagicLogin" {
            Get-DbaLogin -SqlInstance $Instance2 -Login RobsMagicLogin | Should BeNullOrEmpty
        }
    }
    Context "BackupFiles" {
        It " Should have Backup file"{
            Test-Path C:\MSSQL\BACKUP\ROB-XPS\DEMOdbareports\DIFF\ROB-XPS_DEMOdbareports_DIFF_20170921_072547.bak | Should Be $true 
        }
    }
    Context "XEL Fiies"{
        It "SHould have XEL files" {
            Test-Path C:\MSSQL\BACKUP\Basic_Trace_0_131518780835570000.xel | Should be $true
        }
        Context "Databases"{
            It "should have a database called $database" {
                Get-DbaDatabase -SqlInstance $Instance3 -Database $database | Should Not BeNullOrEmpty
            }
        }
    }
}