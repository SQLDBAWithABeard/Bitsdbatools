# PSConfEU - Journey through our Git history

A magical and sometimes mysterious journey through our git history that shows the things we learnt as we developed this project.

## Top Highlights

- [Started moving towards using modules & using PSDefaultParameters to make connecting to the containers easy](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/bf23bbfa67c2e4cc602f788280c2a634146b1e5c)
  - [Meant we could tidy up the chapters](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/7ac9e0015a56aec909800ab6bde2a3683598acef)
  - [Also led us to find a bug in dbatools](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/26b5579ec2c140862338d902129a5b496233fbac)
  - [Which was then fixed](https://github.com/dataplat/dbatools/issues/8193)
- [With dbachecks we can add in custom checks to test anything](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/021ae36305392818cac0a12cff9f0c7ded3affb1)
  - As we found things that broke other demos – add tests so it doesn’t happen again
    - [Ags](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/c6b4c238c7fb5a360ee9e8b5e7c3a30d85cc59f4)
    - [Dbs on instance](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/4adef68df767ab6ab742752694d3ff1ece352781)
    - [Backup files](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/2ac591c6011d8cc1ee303d0dcecd0c12f9b339dd)
    - [Logins](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/434b49280be8aad54ad39c98f3a22280fbb36fba)
- [Issues with 2nd container not being rebuilt](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/7568b8d40f90f5d9e0ffc1c10171cc09f3fb14fc)
  - [Only way to rebuild](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/35bebbde5a5a40bcfdf9d3279d5f781944454a0c)
  - [Still trying](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/8759f98b163d31668857cc4550f72452fcfcd401)
  - [Bump version & tag](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/a495ac499d3e54fb706156234a4d7c040999365f)
  - [Update devcontainer with latest tag number](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/a495ac499d3e54fb706156234a4d7c040999365f)
  - [Worked! Commit from GH action](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/8609fd08d13752fb68a304664d1eb83675dacdb6)
  - [Almost – need the image name](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/c6774ccbd1ad0f005676dd309d60ca20340a1b12)
  - [Build 2nd image too](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/3e9d9f480e2600d023f25c0ca006a4d8774e2015)
  - [GH action removed “ and image name so couldn’t build](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/2c8ada91fa8dbfa7536f8f8997f14d487d42e786)
  - [Fixed the image name, but it stole the “ again](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/aed53d9d92b71cb83833c6b02a7598e9857c2d38)
  - [And again](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/b26a6c5b5a68e3bba86250ddd43b7a2edf1bdab8)
  - [Just ditch the quotes all together](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/b26a6c5b5a68e3bba86250ddd43b7a2edf1bdab8)
  - [Worked – no quote mismatch, both container image versions updated by the Github Action](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/42ad01bb171a63aaccc7719fcf48c4445fb58e0f)
- [Profile making the powershell session crash](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/04001f00f77fc448b37233d32fa22d80af49796f)
  - [Related to having credentials specified twice](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/42ea471c2c68c58b74ae750ae0bbc0c3eb1a2ca0)
- [Another cat attack?](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/4543b34c2dd646fbab4b63322a06eb2ed5c4e859)
- [Tidy up](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/2a1ede4f9ad421b87f162b7b7327e99bba6cce53)
  - [Steady Rob - we need the dockerfile…](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/1d46e0b01a29f40e359e9527fbe364abc806356d)
- [Too close to home unfortunately](https://github.com/SQLDBAWithABeard/Bitsdbatools/blob/d53ca9ac5866d7f4891e4cf4fd1fc8c05eeba6cb/Game/JessAndBeard.psm1)

## More Fun

- [Resolving Git line ending issues in containers](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/7909162c4d9d546ba0bdaca903261e85feab027d)
- [Install modules at the same time to improve performance](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/f18ab5c2091d958c5b01a41e987eebce28a0baa2)
- [Since we’re in a devcontainer we can set vscode settings for everyone](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/eeeeb0d45fad96578dbc4339b9e9b30458d3fcd9)
- [Added Assert-Correct](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/2519af94059821388ef23588edb1776efc8336d0)
- Lots of testing things as we went - sometimes they worked, sometimes they didn't:
  - [Change entrypoint](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/fee2800bd980ec9233cca08357a14f3baa1e8f3a)
  - [Rollback change, breaks profile](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/c147660e8a35d37a8f73a3342bafa06f53b1f968)
- [Cats also tried to ‘help’](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/591d25c5db39a1c798977c1f3ec1562c81d96aa1)
- [To add new chapters](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/6baf274df75645248b3e1d1fcd8db3dbf66d8ab2)
  - Add to Get-Index
  - Add to Assert-Correct
- [Add Github Action to rebuild the container and push to docker hub](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/9c7f163bf846da5830ca8f7a9814c4c57e2e75fc)
  - [Try again...](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/4e2c41de0b686b2c0081f7d035157a362c8db8b3)
  - [and again...](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/b978825a0b5381c2ddde0682e8c5839a417cd52a)
  - [Add triggers to GH actions for more files](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/96e72f647e01523acffc511ad5d002b502f810cf)
  - [Change devcontainer to be build from docker hub image](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/602aed162fa18dffe5d65a0db4e1fe75dce78426)
- [Fix Github action syntax](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/ffeca9dbb43033fae48fc1e5587ca64e14884974)
- [Using latest on image to see if it’ll pull the right image from docker hub](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/3f4d0046c4b330ba68d2631d5fe8a0a4d855433d)
- [Difference between true and false?](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/41e895e055703d72355f955ddc12197f1463f305)
- [PSDefaultParam in dbachecks](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/9fcd64af0977102f57489bdddca1722f3b4bfa9c)
- [Change terminal.integrated.shell.linux to use new version](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/3bf4caf6d3cda39fb2d2160fa227ad81b60ac0b5)
- Adding silliness - to add to the fun!
  - [tic tac toe](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/bd3b8f2d6010419de23156dc9035c45ea0768b97)
  - [Pacman cls](https://github.com/SQLDBAWithABeard/Bitsdbatools/commit/921ed00e4d451cd28b37f85500374453c202cdb9)
