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

cls

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

# We can also add new groups
$regServerGroup = @{
    SqlInstance = $dbatools1
    Name        = 'Test-2022'
    Description = 'This is test servers that are SQL 2022'
}
Add-DbaRegServerGroup @regServerGroup

# and then add a server to the group
$regServer = @{
    SqlInstance = $dbatools1
    ServerName  = $dbatools1 # note I'm reusing dbatools1 for this server as don't have a third container to play with
    Name        = 'Shiny 2022 Test Server'
    Group       = 'Test-2022'
}
Add-DbaRegServer @regServer

# Get all registered server groups again - they are now our training day containers
Get-DbaRegServerGroup -SqlInstance $dbatools1 | Format-Table


# Now that we have registered servers in a group we can use them as a group
Get-DbaRegServer -SqlInstance $dbatools1 -Group 'Production' 

## Broken on Linux - but would work for windows...

    # Get all the databases on the instances
    Get-DbaRegServer -SqlInstance $dbatools1 -Group 'Production' | Get-DbaDatabase 

    # Make sure they are patched to the latest version
    Get-DbaRegServer -SqlInstance $dbatools1 -Group 'Production' | Test-DbaBuild -Latest

# We can also move registered servers between groups 
Move-DbaRegServer -SqlInstance $dbatools1 -Name dbatools1 -Group Test

# We can also move groups - if we want to nest the Test-2022 group in the Test group
Move-DbaRegServerGroup -SqlInstance $dbatools1 -Group 'Test-2022' -NewGroup 'Test'

# Let's review the groups again
Get-DbaRegServerGroup -SqlInstance $dbatools1 | Format-Table

# What about migrations?!
Get-DbaRegServerGroup -SqlInstance $SQLInstances | Format-Table

Copy-DbaRegServer -Source $dbatools1 -Destination $dbatools2

Get-DbaRegServerGroup -SqlInstance $SQLInstances | Format-Table

# Post migration we'll need to clean up the old server - dbatools1
# Remove all registered servers 
Remove-DbaRegServer -SqlInstance $dbatools1 -Confirm:$false

# Remove all groups too
Remove-DbaRegServerGroup -SqlInstance $dbatools1 -Confirm:$false


# How do we find instances in our environment to add to our CMS?

Find-DbaInstance -ComputerName $SQLInstances -OutVariable discoveredInstances

Get-Help Find-DbaInstance -Full | Out-String | code -

$discoveredInstances.foreach{
    Add-DbaRegServer -SqlInstance $dbatools1 -ServerName $psitem.SqlInstance 
}

# Choose your adventure
Get-GameTimeRemaining

Get-Index