
#region Write Your First Pester Test

## First decide what you are going to test (WHat are we going to test for?)

Maxdop 

## Second No decide EXACTLY what you are goingn to test!!

Max Dop should not be 1

## Third understand how to get the value with PowerShell

Test-DbaMaxDop -SqlInstance localhost 

(Test-DbaMaxDop -SqlInstance localhost).CurrentInstanceMaxdop | Select-Object  -First 1

## Fourth understand what is returned if the value isnt as expected
## Know what makes your test fail as well as suceed



## Write a Pester test
$Instances = 'localhost'
foreach ($Instance in $Instances) {
    Describe "Testing SQL Server Configuration for $Instance" -Tag Tests, Configuration, Integration, NewBuild, $Instance {
        Context "CPU" {
            if ((Get-DbaDatabase -SqlInstance $Instance -ExcludeAllSystemDb).Name -contains 'Sharepoint_Config') {
                    It "MaxDop setting should be correct" {
                        (Test-DbaMaxDop -SqlInstance $Instance).CurrentInstanceMaxdop | Select-Object  -First 1 | Should  -Be 1 -Because "This is a Shareoint server and it is required"
                    }
            }
            else {
                It "MaxDop setting should be correct" {
                    $Results = Test-DbaMaxDop -SqlInstance localhost
                    $results[0].CurrentInstanceMaxdop  | Should -Be $Results[0].RecommendedMaxDop  -Because "This should be $($Results[0].RecommendedInstanceMaxDop) following the web-page in the help"
                }
            }
        }
    }
}
#region If everyone is shy do this

$SQLInstances = $dbaSQL1, $dbaSQL2
$SQLInstances.ForEach{

    Describe "This is a series of tests for the SQL Server $($_)" {
        Context "Configuration - This is a scope for grouping our tests" {
            It "Max Memory Should Be  24Gb" {
                (Get-DbaMaxMemory -SqlInstance $_ -SqlCredential $sacred).SQLMaxMb | Should Be 24576
            }
            It "Minimum Memory SHould Be Less than 1Gb" {
                (Get-DbaSpConfigure -SqlInstance $_ -SqlCredential $sacred).Where{$_.ConfigName -eq 'MinServerMemory'}.RunningValue | Should BeLessThan 1024
            }
            It "Minimum Memory SHould Be Less than 1Gb AND Max Memory Should Be lesthan 24Gb" {
                (Get-DbaSpConfigure -SqlInstance $_ -SqlCredential $sacred).Where{$_.ConfigName -eq 'MinServerMemory'}.RunningValue | Should BeLessThan 1024
                (Get-DbaMaxMemory -SqlInstance $_ -SqlCredential $sacred).SQLMaxMb | Should Belessthan 24576
            }
        }

    }

}
# SMILE
#endregion

#endregion
