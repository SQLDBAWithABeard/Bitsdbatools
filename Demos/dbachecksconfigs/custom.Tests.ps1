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
$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe "dbatools1 should not have the additional databases already" -Tags NoDatabasesOn1 , $Filename {
    Context  "Databases Should not exist" {
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
            },
            @{
                Name = 'pubs'
            },
            @{
                Name = 'Northwind'
            }
        )
        It "<Name> Database should not exist on dbatools1" -TestCases $TestCases {
            Param($Name)
            $Name | Should -Not -BeIn $Databasesondbatools1 -Because "It will make demos pretty tricky"
        }
    }
}

Describe "There should be no snapshots" -Tags NoSnapshots , $Filename {
    Context "No Snapshots Here please" {
        It "<SqlInstance> Should not have any snapshots" -testCases @(
            @{
                SqlInstance = 'dbatools1'
            },
            @{
                SqlInstance = 'dbatools2'
            }
        ) {
            Param(
                $SqlInstance
            )
            Get-DbaDbSnapshot -SqlInstance $SqlInstance | Should -BeNullOrEmpty -Because "We dont want none of them snapshots here wasting our space"
        }
    }
}

Describe "There should be no Availabiity Groups" -Tags NoAgs , $Filename {
    Context "No Ags Here please" {
        It "<SqlInstance> Should not have any Availability Groups" -testCases @(
            @{
                SqlInstance = 'dbatools1'
            },
            @{
                SqlInstance = 'dbatools2'
            }
        ) {
            Param(
                $SqlInstance
            )
            Get-DbaAvailabilityGroup -SqlInstance $SqlInstance | Should -BeNullOrEmpty -Because "We dont want none of them snapshots here wasting our space"
        }
    }
}



