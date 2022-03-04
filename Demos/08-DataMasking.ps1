<# 

______      _         ___  ___          _    _             
|  _  \    | |        |  \/  |         | |  (_)            
| | | |__ _| |_ __ _  | .  . | __ _ ___| | ___ _ __   __ _ 
| | | / _` | __/ _` | | |\/| |/ _` / __| |/ / | '_ \ / _` |
| |/ / (_| | || (_| | | |  | | (_| \__ \   <| | | | | (_| |
|___/ \__,_|\__\__,_| \_|  |_/\__,_|___/_|\_\_|_| |_|\__, |
                                                      __/ |
                                                     |___/ 

#>
# Data masking

cls

## Find sensitive data in your database
$piiSplat = @{
    SqlInstance     = $dbatools1
    Database        = "Northwind"
    Table           = "Customers"
}
Invoke-DbaDbPiiScan @piiSplat | Format-Table

# Find masking types to use
Get-DbaRandomizedType | Select-Object Type -ExpandProperty type -Unique
Get-DbaRandomizedType -RandomizedType Person | Select-Object Subtype -ExpandProperty Subtype -Unique

# Get types based on pattern
Get-DbaRandomizedType -Pattern "Credit"
Get-DbaRandomizedType -Pattern "Name"

## Generate data
Get-DbaRandomizedValue -DataType int -Min 10000
Get-DbaRandomizedValue -RandomizerType Name -RandomizerSubType FirstName -Local 'US'

Get-DbaRandomizedValue -RandomizerType address -RandomizerSubType zipcode
Get-DbaRandomizedValue -RandomizerType address -RandomizerSubType zipcode -Format '#####'

# Mask the data
## generate a file
$maskConfig = @{
    SqlInstance   = $dbatools1
    Database      = 'Northwind'
    Table         = "Customers"
    Column        = "Address", "PostalCode", "Phone" 
    Path          = ".\Masking\"
}
New-DbaDbMaskingConfig @maskConfig -OutVariable configFile

## Modify the file manually
code $configFile.FullName

## check your file - returns nothing if good - errors if errors
Test-DbaDbDataMaskingConfig  -FilePath $configFile.FullName

<#
Table    Column           Value    Error
-----    ------           -----    -----
Customers Address         KeepNull The column does not contain all the required properties. Please check the column
Customers PostalCode      KeepNull The column does not contain all the required properties. Please check the column
Customers Phone           KeepNull The column does not contain all the required properties. Please check the column
#>

# View data before!
Invoke-DbaQuery -SqlInstance $dbatools1 -Database NorthWind -Query 'select top 5 CustomerId, ContactName, Address, City, PostalCode, Phone from dbo.Customers order by CustomerId' | Format-Table

# Mask the data
$maskData = @{
    SqlInstance   = $dbatools1
    Database      = 'Northwind'
    FilePath      = '.\Masking\dbatools1.Northwind.DataMaskingConfig.json'
    Confirm       = $false
}
Invoke-DbaDbDataMasking @maskData -verbose  -enableexception

# View data after!
Invoke-DbaQuery -SqlInstance $dbatools1 -Database NorthWind -Query 'select top 5 CustomerId, ContactName, Address, City, PostalCode, Phone from dbo.Customers order by CustomerId' | Format-Table

# Choose your adventure
Get-GameTimeRemaining

Get-Index