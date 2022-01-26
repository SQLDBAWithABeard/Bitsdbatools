## dbachecks
## Just a failsafe ;-)
 Return "This is a demo Beardy!"

## Can I take action on a failing test?

## NO

## Well Not while they are running!

## Afterwards with a bit of coding you can

## Let's test for my BackupCompression statuses

Invoke-DbcCheck -Tag DefaultBackupCompression

## Drat - Need to do soething about that

$TestResults = Invoke-DbcCheck -Tag DefaultBackupCompression -Show None -PassThru

## Which tests failed?
$TestResults.TestResult.Where{
   $_.Result -eq 'Failed'
} | Select Name, Result

## So we have a little work to do here to do this

$TestResults.TestResult.Where{
    $_.Name -like '*Default Backup Compression is set to True on*' -and $_.Result -eq 'Failed'
}.foreach{
    ## Get the instance
    $Instance = $_.Name.Split()[-1]
    ## Set the value
    Set-DbaSpConfigure -SqlInstance $Instance  -ConfigName 'DefaultBackupCompression' -Value 1
}

## Now lets run our test again

Invoke-DbcCheck -Tag DefaultBackupCompression