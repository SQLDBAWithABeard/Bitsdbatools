## Lets spin up a couple of docker images
cd Git:\PSConfAsiaPreCon
cd '.\Slides and Demos\07 - Linux & docker\containers'

## This works really well
.\stages.ps1

## They are just SQL Images so we can connect in SSMS

.\stages\cleanup.ps1

## uses the docker compose to create an image and use it

## but you can also 

docker run -d -p 15789:1433 --env ACCEPT_EULA=Y --env sa_password=Singapore1 --name MyFirstContainer microsoft/mssql-server-windows-developer:latest

Measure-Command { docker run -d -p 15790:1433 --env ACCEPT_EULA=Y --env sa_password=Singapore1 --name MySecondContainer microsoft/mssql-server-windows-developer:latest}

docker ps 

docker inspect MyFirstContainer 

# Copy IP address and connect in SSMS

## then kill it off

docker rm MyFirstContainer --force
docker rm MySecondContainer --force

# Then build it again

docker run -d -p 15789:1433 --env ACCEPT_EULA=Y --env sa_password=Singapore1 --name MyFirstContainer microsoft/mssql-server-windows-developer:latest

## Switch to linux containers in taskbar (need to have at least 3 Gb of memory assigned to docker)

docker run -d -p 15789:1433 --env ACCEPT_EULA=Y --env SA_PASSWORD=Singapore1 --name linuxcontainer microsoft/mssql-server-linux:2017-latest

docker logs linuxcontainer --tail 50 -f

docker exec -it linuxcontainer bash

cd /opt/mssql-tools/bin

./sqlcmd -S. USA

## open linux.sql and run in vscode

