# FreeBSD CheckMK Agent Installer

This is a small helper repo to ease the pain of installing the agent script
for the [CheckMK](https://checkmk.com/) monitoring tool on FreeBSD systems.

## WARNING

Use this piece of code on your own risk!

Please be aware, that in the current state the installer script might not check
properly whether or not any of the configurations to be written are already
there or existing ones will be mended/aligned properly.

## History

This script came to live while actively using the FreeBSD-base
[OPNsense](https://opnsense.org/) firewall, where global config files are
overwritten on installation of updates every now and then. Me being a kind of
a lazy person, I did not want to dig into the question of how to persist these
configs over updates, so here we are ;)

## Usage

The installer script needs two arguments.  
The first one is the IP of your CheckMk Server needed to prevent any other IP
from accessing the information provided by the installed service. The second
one is the location of the CheckMk agent file to deploy.  
Example:
```bash
./install_checkmk_agent.sh 192.168.0.139 ./check_mk_agent.freebsd
```
