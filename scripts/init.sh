#!/bin/bash

# The purpose of this script is to provide a one-fire method of creating all
# virtual machines in the pe demo stack without bringing them up simultaneously
# or exhausting the 16GB of memory on a Macbook Pro (the hardware this stack is
# targeted for).

main()
{
  set -ex

  # Bring up the core demo environment infrastructure. That's master and gitlab.
  vagrant up /master/

  # Iterate over every general-purpose vm in the stack. Demo-specific machines
  # are omitted. Provision them, then shut them down and snapshot them.
  for vm in $(vagrant status '/[ab]\.(pdx|syd)\./' | awk '/puppet.vm/{ print $1 }'); do
    vagrant_up_snap_down provisioned $vm
  done

  # Snapshot the core. Note that no manual port forwarding assignments have
  # been made to these hosts. This is because we don't know how to set the
  # ports while the VMs are running, and shutting them down introduces other
  # problems like how to boot them back up and retain the port settings without
  # losing the shared folders.
  vagrant provision --provision-with hosts,puppet_complete /master/
  vagrant snap take --name provisioned /master/

  set +ex
}

# Bring up a vm, halt it, take a snapshot. Arguments:
#  - snapshot_name: the name to give the snapshot
#  - vm: the name of the vagrant machine
vagrant_up_snap_down()
{
  snapshot_name="$1"
  instance_name="$2"

  vagrant up "$instance_name"

  # We don't yet have a clean way of accounting for Vagrant waiting for puppet
  # to reboot the Windows VMs, which puppet WILL do. Therefore, hack: if it
  # looks like a Windows VM, sleep awhile before shutting down and taking the
  # snapshot.
  if [[ "$instance_name" =~ server2012 ]]; then sleep 180; fi

  vagrant halt "$instance_name"
  assign_ssh_port_forwarding "$instance_name"
  vagrant snap take --name "$snapshot_name" "$instance_name"
}

# Function to work around the fact that Vagrant won't resolve port conflicts
# when resuming snapshots; assigns a likely unique ssh port number to the vm
assign_ssh_port_forwarding()
{
  set +e
  id=$(cat $(dirname $(dirname $0))/.vagrant/machines/$1/virtualbox/id)
  VBoxManage modifyvm "$id" --natpf1 delete ssh
  VBoxManage modifyvm "$id" --natpf1 "ssh,tcp,127.0.0.1,$sshport,,22"
  let "sshport += 1"
  set -e
}

# Initialize the sshport variable to a value between 2600 and 3600
sshport=$RANDOM
let "sshport %= 1000"
let "sshport += 2600"

# Start the script at the main() function
main "$@"
