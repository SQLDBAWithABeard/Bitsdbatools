# Rob & Jess' Magical Bits Training Day Repository

This is the repository we'll be using for our SQLBits Training Day.

We recommend downloading the repo and getting the local demo environment setup on your laptop. This way you can follow along with the demos.

## Prerequisites:

- [Docker](https://www.docker.com/get-started)
- [git](https://git-scm.com/downloads)
- [VSCode](https://code.visualstudio.com/download)
- [`Remote Development` Extension for VSCode](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

## Setup

1. Download the repo from GitHub
    ```PowerShell
    # change directory to where you'd like the repo to go
    cd C:\GitHub\

    # clone the repo from GitHub
    git clone https://github.com/SQLDBAWithABeard/Bitsdbatools

    # move into the folder
    cd .\Bitsdbatools\

    # open VSCode
    code .
    ```

754662. Once code opens, there should be a toast in the bottom right that suggests you 'ReOpen in Container'.
1. The first time you do this it may take a little, and you'll need an internet connection, as it'll download the container images used in our demos
45784578. Open a pwsh console and start your adventure... (Note it is better in a vanilla pwsh session than in the Integrated Terminal)


## Rebuild

Only way to properly rebuild to ensure that all volumes etc are removed is to

cd to .devcontainer in a diff window

`docker-compose -f "docker-compose.yml" -p "bitsdbatools_devcontainer" down`