# Vagrant Puppet Enterprise Stack

#### Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Puppet Master Setup](#installation-and-puppet-master)
    * [Quickstart](#quickstart)
    * [Next Steps](#next-steps)

## Overview
This project provides a demo environment for running a Puppet master and several agents.

## Prerequisites
This tool is built on top of a few different technologies, mainly VirtualBox and Vagrant, so you'll need to ensure that those are present before you continue. You'll also need to have the Git tools installed to checkout the repository.

1. Install [Virtual Box](https://www.virtualbox.org/wiki/Downloads).
2. Install [Vagrant](http://vagrantup.com/).
3. Install the required Vagrant plugins:
* `$ vagrant plugin install oscar`
* `$ vagrant plugin install vagrant-hosts`
* `$ vagrant pluing install vagrant-reload`
* `$ vagrant plugin install vagrant-multiprovider-snap` (optional, but you won't have snapshot functionality if you don't install it)

In addition, keep in mind the raw cpu and memory requirements.  The master is 2CPU and 8G of memory.

## Puppet Master Setup
### Quickstart
After getting the pre-reqs setup, run scripts/init.sh.  This will stand up the master and all configured agents.  For all agents, the will be snapshotted after provisioning and then shutdown.  The master will be left running.  To complete the setup run `vagrant hosts list` and update your hosts file.

The new master is already fully deployed, running with a hostname of `master.inf.puppet.vm`.  In additon, an internal Git server is running on the new master [here](http://master.inf.puppet.vm:3000).

### Next Steps
Once the master is up and running, you'll need to add your SSH keys to the master.  Update `/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa` and `/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub` with your keys.  Finally, login to the Git server ([here](http://master.inf.puppet.vm:3000)) and update the puppet users ssh keys with your own public.  Code manager deployments will now run successfully.

> Note: The default Puppetfile used in this environment assumes you have access to the `puppetlabs` GitHub organization.  If you do not code deployments will fail until you get access or update the Puppetfile.

