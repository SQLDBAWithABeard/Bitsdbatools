# Docker Lab

## Prerequisites:

* A web browser with internet.
* >=6GB of RAM on your computer
* 12GB for the mssql image
* Windows 10 with either Professional or Enterprise licenses, or Windows Server 2016. Virtualization works but is unsupported by everyone.

## Installing Docker

* https://docs.docker.com/docker-for-windows/install/#download-docker-for-windows
* Choose the "Stable Channel" which should generally redirect to https://download.docker.com/win/stable/InstallDocker.msi
* Once docker is installed, type "docker" at the Start menu and run.
  * This will perform some fairly invasive steps for you, consider using virtualization.
* You will need to log off and on again.
* You will need to right click the system tray docker icon and choose the _Change to Windows Containers_ option, which will usually require a restart.

### Problems you may encounter

Before doing anything else, if you are having issues, restart your computer.

Errors messages regarding Hyper-V:

* You may need to reinstall hyper-v. https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v
* Hardware virtualization will need to be enabled on your machine, this may be a BIOS setting.

Other common errors:

* https://rominirani.com/docker-for-windows-startup-errors-fb5903431eda

## Start the containers and run the tests

Launch an Administrative PowerShell session, change your current directory to the containers folder.

* type `.\stages.ps1` and hit enter.
* All docker containers will be built, stood up, and made available for your user.

**This process needs to be done online before the session as we will not have internet access.**

Docker images will need several minutes to download a significant amount of data, and each down/up cycle for the images could take significant time to come up and down, in my environment ~75 seconds. 

## Troubleshooting

Issue: During building, you receive the error `HNS failed with error : The parameter is incorrect.` and the build hangs.
Resolution: This is currently an issue with Windows 10 networking, please run `Get-NetNat | Remove-NetNat` in an elevated prompt and rerun the build process.

Issue: There is an error message regarding permissions or access.
Resolution: Verify you are running an Administrative PowerShell session.

## Notes

* If you have VirtualBox or other Virtualization services on this machine, they may need to be temporarily disabled for Hyper-V (which is the mechanism for Windows in Docker on Windows) to work.

## Useful Commands

`.\stages.ps1` - Run the cleanup, setup, test, and demo scripts, feel free to add your own code to the stages folder and call it from this to make it easy!
`. .\constants.ps1` - Dot source the constants file to automatically load the the username, password, built in credential, and the SQL Servers into your console session.
`docker-compose down` - If you want to bring the docker images down, this must be run within the folder where the docker-compose.yml file lives.