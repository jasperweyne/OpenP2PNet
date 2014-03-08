OpenP2PNet
==========

OpenP2PNET is a peer-to-peer network API, in the form of a script-library for GameMaker projects. The project was written by Jasper Weyne, and is currently maintained by Rty Development, led by Jasper Weyne.

How-to use
==========
To keep your implementation up-to-date with our repository, we recommend to use git submodules. This way, it's easy to syncronise your project. To use it, execute the following commands in your terminal.
```
cd /your/gamemaker/project.gmx
mkdir "scripts"
cd "scripts"
git submodule add https://github.com/RtyDevelopment/OpenP2PNet.git OpenP2PNet
```
Then open from your current folder your *.project.gmx file, and within the 'scripts' xml-tag, add the contents found in 'scripts/OpenP2PNet/project-gmx-content.txt'.
Then, start GameMaker:Studio, open your project, and load the constants from 'scripts/OpenP2PNet/scr/constants.txt'
Thereafter, execute the following commands
```
cd /your/gamemaker/project.gmx
git commit -m "Added OpenP2PNet network API" -m "Please execute 'git pull && git submodule init && git submodule update' on first pull from this commit or later"
git push
```
Other clients should now do a pull as described in the commit
