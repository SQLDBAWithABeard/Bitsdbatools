
Set-Location SQLSERVER:\SQLRegistration
Set-Location 'Database Engine Server Group'
Set-Location Rob-XPS
New-Item '01 - linux'

Set-Location Git:\PSConfAsiaPreCon

if ((Get-Service MsDtsServer140).Status -ne 'Running'){
    Start-Service MsDtsServer140
}

$query1 = " RAISERROR ('A terrible thing happened',  20,  20  ) WITH LOG;  "
$query2 = " RAISERROR ('A really terrible thing happened',  21,  20  ) WITH LOG;  "
$query3 = " RAISERROR ('A stupendously terrible thing happened',  22,  20  ) WITH LOG; "
$queries = $query1, $query2, $query3

$i = 10
while($i -gt 0){
    foreach($Query in $Queries){
        Invoke-Sqlcmd2 -ServerInstance $ENV:COMPUTERNAME -Database master -Credential  $sacred  -Query $query  -ErrorAction SilentlyContinue
    }
    $i --
}
