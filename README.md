# ofinterest

!! Proof of concept - VERY MUCH WORK IN PROGRESS !!

In a pinch, basically it's intended to periodically keep an eye on certain objects on a collection of remote hosts.

It's intended to be modular, right now there is only one module. In theory you could monitor all kinds of objects, like checking to see if new devices have been added, etc.

Files

Right now the only module, you provide a list of files and if they exist on the remote host they'll be diff'd against a copy of the file taken the last time the script ran.

A copy of the diff is kept on disc, optionally if the email parameter is set in the config file it'll email the diff to you.

Config file users string names in CAPS so you can easily spot in the .sh where they're being used, this probably isn't standard practice but that's how I chose to do it right now.

INSTALLATION

Edit the config file, tell it where the base directory is, if you're checking files that are only readable by certain users you'll want to set SSHUSER to be root, otherwise you can use a non-root user.


TODO

- add more modules
- work out how to specify which modules get run against what host
- check file permissions, work out if we can use sudo to check file if we don't have access
