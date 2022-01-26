#region storage for the migration
# https://stuart-moore.com/dbatools-copy-dbadatabase-and-start-dbamigration-now-supporting-azure-storage-and-azure-managed-instance/
# connect to Azure
Connect-AzAccount

# sub check
Get-AzContext

# create resource group if it doesn't exist
$RGName = 'BeardStorage'
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
     Name = 'mimigration'
     SkuName = 'Standard_LRS'
     AccessTier = 'Hot'
     ResourceGroupName = $RGName
     Location = 'West Europe'
     Tag = @{ Owner="Beard"; Environment="demos" ; Type="Mananged Instance Migration"}
     Kind = 'BlobStorage'
 }
 New-AzStorageAccount @newAzStorageAccountSplat

#Get the Azure Storage Account keys
$getAzStorageAccountKeySplat = @{
    ResourceGroupName = $RGName
    Name = $NewAzStorageAccountSplat.Name
}
$AzStorageKeys = Get-AzStorageAccountKey @getAzStorageAccountKeySplat 

# Create a Storage Context
$newAzStorageContextSplat = @{
    StorageAccountName = $NewAzStorageAccountSplat.Name
    StorageAccountKey = $AzStorageKeys[0].Value
}
$AzStorageContext = New-AzStorageContext @newAzStorageContextSplat

#Create a blob container 
$newAzStorageContainerSplat = @{
    Context = $AzStorageContext
    Name = 'sqlbackups'
}
$AzStorageContainer = New-AzStorageContainer @newAzStorageContainerSplat

#Create a Shared Access Policy giving (r)ead, (w)rite, (l)ist and (d)elete permissions for 1 year from now
$SharedAccessPolicy = @{
    Context = $AzStorageContext
    Policy = $AzStorageContext.StorageAccountName+"Policy2"
    Container = $newAzStorageContainerSplat.Name
    ExpiryTime = (Get-Date).ToUniversalTime().AddYears(1)
    Permission = "rwld"
}
$AzSharedAccessPolicy = New-AzStorageContainerStoredAccessPolicy @SharedAccessPolicy

#Get the Shared Access Token
$newAzStorageContainerSASTokenSplat = @{
    Context = $AzStorageContext
    Policy = $SharedAccessPolicy.Policy
    Name =  $newAzStorageContainerSplat.Name
}
$AzSas = New-AzStorageContainerSASToken @newAzStorageContainerSASTokenSplat

#We need the URL to the blob storage container we've created:
$Url = $AzStorageContainer.CloudBlobContainer.uri.AbsoluteUri

#The SASToken is prefixed with a '?' to make it easy to append to a HTTP querystring, but we don't need it, so use substring(1) to drop it

$SasSql = "CREATE CREDENTIAL [$Url] WITH IDENTITY='SHARED ACCESS SIGNATURE', SECRET='$($AzSas.SubString(1))'"

Invoke-DbaQuery -SqlInstance localhost -Database Master -Query $SasSql 
#endregion 