#region SetUp Variables
$sql0 = 'localhost,15591'
$sql1 = 'localhost,15592'
$BeardContainer = 'localhost,16001'
$estate = $sql0,$sql1,$BeardContainer,'localhost'
$cred = Import-Clixml -Path C:\MSSQL\BACKUP\sqladmin.cred

#endregion