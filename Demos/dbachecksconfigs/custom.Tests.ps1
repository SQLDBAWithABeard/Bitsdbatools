$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe "dbatools2 should not have the databases already" -Tags NoDatabasesOn2 , $Filename {
    Context  "Databases Should not existon dbatools2" {
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
            Get-DbaDbSnapshot -SqlInstance $SqlInstance | Should -BeNullOrEmpty -Because "We don't want none of them snapshots here wasting our space"
        }
    }
}
}
Describe "There should be no backup files in the volume" -Tags NoBackupFiles , $Filename {
    Context "no backup files on dbatools1" {
        It "Volume Should not have any backup files" {
            Get-ChildItem '/var/opt/backups/dbatools1' -ErrorAction SilentlyContinue  | Should -BeNullOrEmpty -Because "We don't want too many backup files - run Remove-Item '/var/opt/backups/dbatools1' -Recurse -Force to fix"
        }
    }
}


foreach($sqlInstance in @('dbatools1', 'dbatools2')){
    Describe "There should be no Availability Groups" -Tags NoAgs , $Filename {
        Context "No Ags on $sqlInstance" {
            It "$sqlInstance Should not have any Availability Groups" {
                Get-DbaAvailabilityGroup -SqlInstance $SqlInstance | Should -BeNullOrEmpty -Because "We don't want none of them snapshots here wasting our space"
            }
        }
    }
}

Describe "There should be expected Logins" -Tags NeedLogins , $Filename {
    Context "Need Logins on dbatools1" {
        $TestCases = @(
            @{
                Name = 'AppAdmin'
            }
            @{
                Name = 'distributor_admin'
            }
            @{
                Name = 'storageuser'
            }
            @{
                Name = 'testlogin'
            }
            @{
                Name = 'TestOrphan1'
            }
            @{
                Name = 'TestOrphan2'
            }
            @{
                Name = 'testuser2'
            }
            @{
                Name = 'webuser'
            }
        )
        It "dbatools1 should have login <Name>" -TestCases $TestCases  {
            param(
                $Name
            )
            Get-DbaLogin -SqlInstance dbatools1 -Login $Name | Should -Not -BeNullOrEmpty -Because "We need to have $Name on dbatools1 for this to work"
        }
    }
}
Describe "There should be expected Stored Procedures" -Tags NeedSps , $Filename {
    Context "Need Stored Procedures on dbatools1" {
        $TestCases = @(
            @{
                Name = 'SP_FindMe' 
            }
        )
        It "dbatools1 should have stored procedure named <Name>" -TestCases $TestCases  {
            param(
                $Name
            )
            Find-DbaStoredProcedure -SqlInstance $dbatools1 -Pattern  $Name | Should -Not -BeNullOrEmpty -Because "We need to have $Name on dbatools1 for this to work"
        }
    }
}
Describe "There should be expected Triggers" -Tags NeedTriggers , $Filename {
    Context "Need triggers on dbatools1" {
        $TestCases = @(
            @{
                Name = 'trg_chaos_monkey' 
            }
        )
        It "dbatools1 should have stored procedure named <Name>" -TestCases $TestCases  {
            param(
                $Name
            )
            Find-DbaTrigger -SqlInstance dbatools1  -Pattern $Name | Should -Not -BeNullOrEmpty -Because "We need to have $Name on dbatools1 for this to work"
        }
    }
}
Describe "There should be expected UDFs" -Tags NeedUDfs , $Filename {
    Context "Need UDFs on dbatools1" {
        $TestCases = @(
            @{
                Name = 'udf_findme' 
            }
        )
        It "dbatools1 should have UDF named <Name>" -TestCases $TestCases  {
            param(
                $Name
            )
            Get-DbaDbUdf -SqlInstance dbatools1 -Name $Name | Should -Not -BeNullOrEmpty -Because "We need to have the UDF $Name on dbatools1 for this to work"
        }
    }
}
Describe "There should be expected Agent Jobs" -Tags NeedJobs , $Filename {
    Context "Need Agent Jobs on dbatools2" {
        $TestCases = @(
            @{
                Name = 'IamBroke' 
            }
        )
        It "dbatools2 should have an Agent Job named <Name>" -TestCases $TestCases  {
            param(
                $Name
            )
            Get-DbaAgentJob -SqlInstance dbatools2 -Job $Name | Should -Not -BeNullOrEmpty -Because "We need to have the job $Name on dbatools2 for this to work"
        }
    }
}
Describe "There should be failed Agent Jobs - Odd I know" -Tags NeedFailedJobs , $Filename {
    Context "Need Agent Jobs to have failed on dbatools2" {
        It "dbatools2 should have failed jobs"  {
            Find-DbaAgentJob -SqlInstance $SQLInstances -IsFailed | Should -Not -BeNullOrEmpty -Because "We need to have failed jobs on dbatools2 for this to work"
        }
    }
}

Describe "There should not be expected Logins" -Tags NeedNoLogins , $Filename {
    Context "Cant have these Logins on dbatools2" {
        $TestCases = @(
            @{
                Name = 'AppAdmin'
            }
            @{
                Name = 'distributor_admin'
            }
            @{
                Name = 'storageuser'
            }
            @{
                Name = 'testlogin'
            }
            @{
                Name = 'TestOrphan1'
            }
            @{
                Name = 'TestOrphan2'
            }
            @{
                Name = 'testuser2'
            }
            @{
                Name = 'webuser'
            }
        )
        It "dbatools2 should not have login <Name>" -TestCases $TestCases  {
            param(
                $Name
            )
            Get-DbaLogin -SqlInstance dbatools2 -Login $Name | Should -BeNullOrEmpty -Because "We need to not have $Name on dbatools2 otherwise how will wee copy them?"
        }
    }
}


