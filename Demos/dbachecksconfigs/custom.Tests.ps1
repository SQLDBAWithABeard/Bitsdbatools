$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe "dbatools2 should not have the databases already" -Tags NoDatabasesOn2 , $Filename {
    Context  "Databases Should not exist" {
        BeforeAll {
            $Databasesondbatools2 = (Get-DbaDatabase -SqlInstance $dbatools2).Name
        }
        $TestCases = @(
            @{
                Name = 'pubs-0'
            },
            @{
                Name = 'pubs-1'
            },
            @{
                Name = 'pubs-10'
            },
            @{
                Name = 'pubs-2'
            },
            @{
                Name = 'pubs-3'
            },
            @{
                Name = 'pubs-4'
            },
            @{
                Name = 'pubs-5'
            },
            @{
                Name = 'pubs-6'
            },
            @{
                Name = 'pubs-7'
            },
            @{
                Name = 'pubs-8'
            },
            @{
                Name = 'pubs-9'
            },
            @{
                Name = 'pubs'
            },
            @{
                Name = 'Northwind'
            }
        )
        It "<Name> Database should not exist on dbatools2" -TestCases $TestCases {
            Param($Name)
            $Name | Should -Not -BeIn $Databasesondbatools2 -Because "It will make demos pretty tricky"
        }
    }
}

Describe "Should not have the additional databases already" -Tags NoDatabasesOn1 , $Filename {
    Context  "Databases Should not exist on dbatools1" {
        BeforeAll {
            $Databasesondbatools1 = (Get-DbaDatabase -SqlInstance $dbatools1).Name
        }
        $TestCases = @(
            @{
                Name = 'pubs-0'
            },
            @{
                Name = 'pubs-1'
            },
            @{
                Name = 'pubs-10'
            },
            @{
                Name = 'pubs-2'
            },
            @{
                Name = 'pubs-3'
            },
            @{
                Name = 'pubs-4'
            },
            @{
                Name = 'pubs-5'
            },
            @{
                Name = 'pubs-6'
            },
            @{
                Name = 'pubs-7'
            },
            @{
                Name = 'pubs-8'
            },
            @{
                Name = 'pubs-9'
            }
        )
        It "<Name> Database should not exist on dbatools1" -TestCases $TestCases {
            Param($Name)
            $Name | Should -Not -BeIn $Databasesondbatools1 -Because "It will make demos pretty tricky"
        }
    }
}

foreach($sqlInstance in @('dbatools1', 'dbatools2')){
Describe "There should be no snapshots" -Tags NoSnapshots , $Filename {
    Context "No Snapshots on $SqlInstance" {
        It "$SqlInstance Should not have any snapshots" {
            Get-DbaDbSnapshot -SqlInstance $SqlInstance | Should -BeNullOrEmpty -Because "We dont want none of them snapshots here wasting our space"
        }
    }
}
}
Describe "There should be no backup files in the volume" -Tags NoBackupFiles , $Filename {
    Context "no backup files on dbatools1" {
        It "Volume Should not have any backup files" {
            Get-ChildItem '/var/opt/backups/dbatools1' -ErrorAction SilentlyContinue  | Should -BeNullOrEmpty -Because "We dont want too many backup files - run Remove-Item '/var/opt/backups/dbatools1' -Recurse -Force to fix"
        }
    }
}


foreach($sqlInstance in @('dbatools1', 'dbatools2')){
    Describe "There should be no Availabiity Groups" -Tags NoAgs , $Filename {
        Context "No Ags on $sqlInstance" {
            It "$sqlInstance Should not have any Availability Groups" {
                Get-DbaAvailabilityGroup -SqlInstance $SqlInstance | Should -BeNullOrEmpty -Because "We dont want none of them snapshots here wasting our space"
            }
        }
    }
}



