<#
  _____                      _   _              __   __                 _____          _                       
 |  ___|                    | | (_)             \ \ / /                |_   _|        | |                      
 | |____  ___ __   ___  _ __| |_ _ _ __   __ _   \ V /___  _   _ _ __    | | _ __  ___| |_ __ _ _ __   ___ ___ 
 |  __\ \/ / '_ \ / _ \| '__| __| | '_ \ / _` |   \ // _ \| | | | '__|   | || '_ \/ __| __/ _` | '_ \ / __/ _ \
 | |___>  <| |_) | (_) | |  | |_| | | | | (_| |   | | (_) | |_| | |     _| || | | \__ \ || (_| | | | | (_|  __/
 \____/_/\_\ .__/ \___/|_|   \__|_|_| |_|\__, |   \_/\___/ \__,_|_|     \___/_| |_|___/\__\__,_|_| |_|\___\___|
           | |                            __/ |                                                                
           |_|                           |___/                                                                 
#>

# Documentation for Everyone
$instanceSplat = @{
    SqlInstance   = $dbatools1, $dbatools2
    Path          = '.\Export\'
    Exclude       = 'ReplicationSettings'
}
Export-DbaInstance @instanceSplat

# Compare the two sp_configure files

# export into a source controlled folder & track changes