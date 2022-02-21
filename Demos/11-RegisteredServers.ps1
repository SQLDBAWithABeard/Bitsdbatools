<#
______           _     _                    _   _____                              
| ___ \         (_)   | |                  | | /  ___|                             
| |_/ /___  __ _ _ ___| |_ ___ _ __ ___  __| | \ `--.  ___ _ ____   _____ _ __ ___ 
|    // _ \/ _` | / __| __/ _ \ '__/ _ \/ _` |  `--. \/ _ \ '__\ \ / / _ \ '__/ __|
| |\ \  __/ (_| | \__ \ ||  __/ | |  __/ (_| | /\__/ /  __/ |   \ V /  __/ |  \__ \
\_| \_\___|\__, |_|___/\__\___|_|  \___|\__,_| \____/ \___|_|    \_/ \___|_|  |___/
            __/ |                                                                  
           |___/                                                                   
#>

# What can we do with registered servers>
Find-DbaCommand 'Registered Servers'

Get-Command '*RegServer*' -Module dbatools 

Get-Help Get-DbaRegServer -Detailed
# Gets list of SQL Server objects stored in 
    # local registered groups
    # azure data studio
    # central management server


# Do we have any local registered servers or from Azure Data Studio?
Get-DbaRegServer

    # Let's get all the registered servers
Get-DbaRegServer -SqlInstance $dbatools1

# Get all registered server groups
Get-DbaRegServerGroup -SqlInstance $dbatools1 | Format-Table

# Get a specific group 
Get-DbaRegServerGroup -SqlInstance $dbatools1 -Group Test | Format-Table

# Returns a SQL Server Registered Server Store Object
Get-DbaRegServerStore -SqlInstance $dbatools1

# These are from Chrissy's lab - they don't work here...
Get-DbaRegServer -SqlInstance $dbatools1 | Remove-DbaRegServer

# Get all registered server groups again - they are now empty
Get-DbaRegServerGroup -SqlInstance $dbatools1 | Format-Table

# Lets add a server to the production group
$regServer = @{
    SqlInstance = $dbatools1
    ServerName  = $dbatools1
    Description = 'This is one of our training day servers'
    Group       = 'Production'
}
Add-DbaRegServer @regServer

# Lets add another server with a friendly name
$regServer = @{
    SqlInstance = $dbatools1
    ServerName  = $dbatools2
    Name        = 'Friendly dbatools2'
    Description = 'This is one of our training day servers'
    Group       = 'Production'
}
Add-DbaRegServer @regServer

# Now that we have registered servers in a group we can use them as a group


## BROKEN BITS!!

# Get all the databases on the instances
Get-DbaRegServer -SqlInstance $dbatools1 -Group 'Production' | Get-DbaDatabase 

# Make sure they are patched to the latest version
Get-DbaRegServer -SqlInstance $dbatools1 -Group 'Production' | Test-DbaBuild -Latest





Copy-DbaRegServer


Move-DbaRegServer
Move-DbaRegServerGroup

Remove-DbaRegServer
Remove-DbaRegServerGroup

