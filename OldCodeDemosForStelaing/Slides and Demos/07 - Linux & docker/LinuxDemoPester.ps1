<#
Pester for the Linux Demo
#>
## Set the local variables

. .\Setup\MachineVars.ps1


try {
    $SQL2017 = Get-DbaInstance  -SqlInstance $Destination2017 
    $Linux = Get-DbaInstance  -SqlInstance $LinuxHyperV -Credential $sacred
}
catch {
    Write-Warning "Failed to get SMO Objects - Some tests are going to FAIL!!"
}


Describe "Linux Demo Requirements" {
    Context "Host" {
        It "Hyper-V Should Be Running" {
            (Get-Service vmcompute).Status | Should Be 'Running'
        }
        It "$LinuxHyperVShould Be Running" {
            (Get-VM $LinuxHyperV -ErrorAction SilentlyContinue).State | Should Be 'Running'
        } 
    }
    Context "SQL Config" {
        It "Windows Backup Compression should be 1" {
            $SQL2017.Configuration.Properties['DefaultBackupCompression'].ConfigValue | Should Be 1
        }
        It "Linux Backup Compression should be 0" {
            $Linux.Configuration.Properties['DefaultBackupCompression'].ConfigValue | Should Be 0
        }
    }
    Context "Generic Commands" {
        It "Should have had Agent Jobs run in the last 2 days" {
            Get-DbaAgentJobHistory -SqlInstance $Linux -StartDate (Get-Date).AddDays(-2) -ErrorAction SilentlyContinue | Should Not BeNullOrEmpty 
        }
    }
}