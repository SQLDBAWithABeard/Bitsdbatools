#region Backup To URI
# All Thanks to Stuart Moore @napalmgram https://stuart-moore.com/

# https://stuart-moore.com/dbatools-copy-dbadatabase-and-start-dbamigration-now-supporting-azure-storage-and-azure-managed-instance/
$ShowAzure = $true
$ShowPath = $false
#region setup
# connect to Azure
Connect-AzAccount

# sub check
Get-AzContext

# variables
$RGName = 'BeardStorage'
$StorageAccountName = 'beardsqlbackups'
$Location = 'West Europe'
$accesskeysqlbackups = 'accesskeysqlbackups1'
$sharedaccesssqlbackups = 'sharedaccesssqlbackups1'
# create resource group if it doesn't exist

if(-not (Get-AzResourceGroup -Name $RGName -ErrorAction SilentlyContinue)){
    $newAzResourceGroupSplat = @{
        Name = $RGName
        Tag = @{ Owner="Beard"; Environment="demos" }
        Location = 'West Europe'
    }
    New-AzResourceGroup @newAzResourceGroupSplat
}

# create storage account
 $newAzStorageAccountSplat = @{
     Name = $StorageAccountName 
     SkuName = 'Standard_LRS'
     AccessTier = 'Hot'
     ResourceGroupName = $RGName
     Location = $Location
     Tag = @{ Owner="Beard"; Environment="demos" ; Type="Mananged Instance Migration"}
     Kind = 'StorageV2'
 }
 if(-not(Get-AzStorageAccount -ResourceGroupName $RGName -Name $StorageAccountName -ErrorAction SilentlyContinue)){
    New-AzStorageAccount @newAzStorageAccountSplat 
 }

 #Get the Azure Storage Account keys
$getAzStorageAccountKeySplat = @{
    Name = $StorageAccountName
    ResourceGroupName = $RGName
}
$AzStorageKeys = Get-AzStorageAccountKey @getAzStorageAccountKeySplat


# Create a Storage Context
$newAzStorageContextSplat = @{
    StorageAccountName = $StorageAccountName
    StorageAccountKey = $AzStorageKeys[0].Value
}
$AzStorageContext = New-AzStorageContext @newAzStorageContextSplat
#endregion

#region Backing up with Access Keys

 #Create a blob container 
 $newAzStorageContainerSplat = @{
    Context = $AzStorageContext
    Name = $accesskeysqlbackups
}
if(-not(Get-AzStorageContainer -Name $accesskeysqlbackups -Context $AzStorageContext -ErrorAction SilentlyContinue)){
    $AzStorageContainer = New-AzStorageContainer @newAzStorageContainerSplat
}else{
    $getAzStorageContainerSplat = @{
        Context = $AzStorageContext
        Name = $accesskeysqlbackups
    }
    $AzStorageContainer = Get-AzStorageContainer @getAzStorageContainerSplat
}

# create a credential - the identity name is important

$newDbaCredentialSplat = @{
    Identity = $StorageAccountName # This 
    SqlInstance = 'localhost'
    Name = 'AzureBackupCredentialForKeys'
    SecurePassword = (ConvertTo-SecureString $($AzStorageKeys[0].Value) -AsPlainText -Force)
}
New-DbaCredential @newDbaCredentialSplat

# backup the database

$backupDbaDatabaseSplat = @{
    AzureBaseUrl = $AzStorageContainer.CloudBlobContainer.Uri.AbsoluteUri
    AzureCredential = 'AzureBackupCredentialForKeys'
    Database = 'AdventureWorks2016_EXT'
    Type = 'Full'
    SqlInstance = 'localhost'
}
Backup-DbaDatabase @backupDbaDatabaseSplat -OutputScriptOnly

#endregion

#region Much better to use Shared Access Signatures

# Create a blob container 
 $newAzStorageContainerSplat = @{
    Context = $AzStorageContext
    Name = $sharedaccesssqlbackups
}
if(-not(Get-AzStorageContainer -Name $sharedaccesssqlbackups -Context $AzStorageContext -ErrorAction SilentlyContinue)){
    $AzStorageContainer = New-AzStorageContainer @newAzStorageContainerSplat
}else{
    $getAzStorageContainerSplat = @{
        Context = $AzStorageContext
        Name = $sharedaccesssqlbackups
    }
    $AzStorageContainer = Get-AzStorageContainer @getAzStorageContainerSplat
}

# Create a Shared Access Policy giving (r)ead, (w)rite, (l)ist and (d)elete permissions for 1 year from now
$SharedAccessPolicy = @{
    Context = $AzStorageContext
    Policy = $AzStorageContext.StorageAccountName+"BeardSql"
    Container = $sharedaccesssqlbackups
    ExpiryTime = (Get-Date).ToUniversalTime().AddYears(1)
    Permission = "rwld"
}
$AzSharedAccessPolicy = New-AzStorageContainerStoredAccessPolicy @SharedAccessPolicy

#Get the Shared Access Token
$newAzStorageContainerSASTokenSplat = @{
    Name = $sharedaccesssqlbackups
    Policy = $SharedAccessPolicy.Policy
    Context = $AzStorageContext
}
$AzSas = New-AzStorageContainerSASToken @newAzStorageContainerSASTokenSplat

#We need the URL to the blob storage container we've created:
$Url = $AzStorageContainer.CloudBlobContainer.uri.AbsoluteUri

# create a credential - the identity name is important

$newDbaCredentialSplat = @{
    Identity = 'SHARED ACCESS SIGNATURE' # This 
    SqlInstance = 'localhost'
    Name = $Url
#The SASToken is prefixed with a '?' to make it easy to append to a HTTP querystring, but we don't need it, so use substring(1) to drop it
    SecurePassword = (ConvertTo-SecureString $($AzSas.SubString(1)) -AsPlainText -Force)
}
New-DbaCredential @newDbaCredentialSplat

# backup the database

$backupDbaDatabaseSplat = @{
    AzureBaseUrl = $AzStorageContainer.CloudBlobContainer.Uri.AbsoluteUri
    Database = 'AdventureWorks2016_EXT'
    Type = 'Full'
    SqlInstance = 'localhost'
}
Backup-DbaDatabase @backupDbaDatabaseSplat -OutputScriptOnly
#endregion

#region backup the entire instance
$databases = Get-DbaDatabase -SqlInstance localhost -ExcludeDatabase AdventureWorks2016_EXT 

$backupDbaDatabaseSplat = @{
    Database = $databases.name
    AzureBaseUrl = $AzStorageContainer.CloudBlobContainer.Uri.AbsoluteUri
    Type = 'Full'
    SqlInstance = 'localhost'
    
}
Backup-DbaDatabase @backupDbaDatabaseSplat -OutputScriptOnly -CopyOnly
#endregion

# get rid of larger backups for demo
$getAzStorageBlobSplat = @{
    Context = $AzStorageContext
    Container = $sharedaccesssqlbackups
}
Get-AzStorageBlob @getAzStorageBlobSplat | Where-Object {$_.Name -notlike 'Beard*'} |Remove-AzStorageBlob

#endregion

#region Managed Instance

# connect to a Managed Instance just the same as a normal instance
$publicEndpoint = 'beardmi.public.e7ea892e35af.database.windows.net,3342'
$ManagedInstance = Connect-DbaInstance -SqlInstance $publicEndpoint 

$ManagedInstance 

Get-DbaDatabase -SqlInstance $publicEndpoint 
Get-DbaAgentJob -SqlInstance $ManagedInstance
Get-DbaCredential -SqlInstance $ManagedInstance
Get-DbaLogin -SqlInstance $ManagedInstance

# we will need the credential to restore from the azure storage
Copy-DbaCredential -Source localhost -Destination $ManagedInstance 

# So, don't run it from the local host unless you are admin!
$command = "Copy-DbaCredential -Source localhost -Destination '$publicEndpoint' -DestinationSqlCredential sqladmin"
Start-Process powershell.exe "-NoExit -Command", ('"{0}"' -f $Command) -Verb RunAs

Get-DbaCredential -SqlInstance $publicEndpoint

# get a list of backupfiles
$getAzStorageBlobSplat = @{
    Context = $AzStorageContext
    Container = $sharedaccesssqlbackups
}
$files = Get-AzStorageBlob @getAzStorageBlobSplat 

# Let's restore the databases to the managed instance
# this will take a few minutes so a good time for a break
foreach($file in $files){
    Restore-DbaDatabase -SqlInstance $publicEndpoint -Path $file.ICloudBlob.uri.AbsoluteUri
}

Copy-DbaAgentJob -Source localhost -Destination $publicEndpoint 
Copy-DbaSysDbUserObject -Source localhost -Destination $publicEndpoint

# check the managed instance

Get-DbaDatabase -SqlInstance $publicEndpoint 
Get-DbaAgentJob -SqlInstance $publicEndpoint
Get-DbaCredential -SqlInstance $publicEndpoint
#endregion

#region Azure SQl Database

$AzSqlServerName = 'beardazsqlserver.database.windows.net'
$a = Connect-DbaInstance -SqlInstance  $AzSqlServerName

$sqldbconstring = 'Server=tcp:beardazsqlserver.database.windows.net,1433;Initial Catalog=AdventureWorks;Persist Security Info=False;User ID=sqladmin;Password=dbatools.IO;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

$AzSql = Connect-DbaInstance -SqlInstance $sqldbconstring
$azsql

$Query = "-- All customer addresses
SELECT c.CompanyName, a.AddressLine1, a.City, 'Billing' AS AddressType
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a
ON ca.AddressID = a.AddressID
WHERE ca.AddressType = 'Main Office'
UNION ALL
SELECT c.CompanyName, a.AddressLine1, a.City, 'Shipping' AS AddressType
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a
ON ca.AddressID = a.AddressID
WHERE ca.AddressType = 'Shipping'
ORDER BY c.CompanyName, AddressType;"

Invoke-DbaQuery -SqlInstance $sqldbconstring -Database AdventureWorks -query $Query
Invoke-DbaQuery -SqlInstance $AzSql -Database AdventureWorks -query $Query

Get-DbaDatabase -SqlInstance $sqldbconstring
Get-DbaLogin -SqlInstance $sqldbconstring
Get-DbaDbccProcCache -SqlInstance $sqldbconstring
Get-DbaDbccMemoryStatus -SqlInstance $sqldbconstring 
Get-DbaDbCheckConstraint -SqlInstance $sqldbconstring -Database AdventureWorks
Get-DbaDbFeatureUsage -SqlInstance $sqldbconstring
Get-DbaDbLogSpace -SqlInstance $sqldbconstring
Get-DbaDbMemoryUsage -SqlInstance $sqldbconstring
Get-DbaDbPageInfo -SqlInstance $sqldbconstring -Database AdventureWorks -Schema SalesLT -Table Address
Get-DbaDbSpace -SqlInstance $sqldbconstring -Database AdventureWorks
Get-DbaErrorLog -SqlInstance $sqldbconstring
Get-DbaExecutionPlan -SqlInstance $sqldbconstring -Database AdventureWorks # takes a while
Get-DbaIoLatency -SqlInstance $sqldbconstring
Get-DbaSpConfigure -SQLInstance $sqldbconstring
Get-DbaTopResourceUsage -SqlInstance $sqldbconstring -Database AdventureWorks
Get-DbaUptime -SqlInstance $sqldbconstring
Get-DbaWaitStatistic -SqlInstance $sqldbconstring 
