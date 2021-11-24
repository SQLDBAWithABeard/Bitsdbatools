
#region Write Your First Pester Test

## First decide what you are going to test (WHat are we going to test for?)















## Second No decide EXACTLY what you are goingn to test!!












## Third understand how to get the value with PowerShell











## Fourth understand what is returned if the value isnt as expected
## Know what makes your test fail as well as succeed














## Write a Pester test





















#region If everyone is shy do this


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
