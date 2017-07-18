#!/bin/bash
#
# Run Puppet agent until we get a successful run with no changes.

LAST_RUN_REPORT="/opt/puppetlabs/puppet/cache/state/last_run_report.yaml"
BINPUPPET="/opt/puppetlabs/puppet/bin/puppet"
FAILPOINT=96 # Fail with this number of run failures
SLEEPTIME=10 # number of seconds to wait before another run

# get status of the last puppet run
get_pupstatus () {
  if [ ! -f "$LAST_RUN_REPORT" ]; then
    echo "incomplete"
  else
    awk '/^status/ { print $2 }' $LAST_RUN_REPORT
  fi
}

main () {
  local puppet_runs=0 # Keep track of number of Puppet runs
  local puppet_tries=$FAILPOINT
  local puppetrun_exitcode=0
  local puppetrun_status=$( get_pupstatus )

  # Bypass if last Puppet run was successful...
  if [ "$puppetrun_status" = "unchanged" ]; then
    echo "Last Puppet run was successful, continuing..."
  fi

  # ... otherwise, loop through until we get a good run or run too many times.
  while [ "$puppetrun_status" != "unchanged" ]; do

    if [ ! -f "$BINPUPPET" ]; then
      echo "Puppet doesn't appear to have installed correctly.  Exiting script."
      exit 1
    fi

    $BINPUPPET agent -t  > /dev/null 2>&1
    puppetrun_exitcode=$?

    if [ "$puppetrun_exitcode" -eq 1 ]; then
      echo "Puppet run failed or run may be in progress. Trying ${puppet_tries} more time(s)."
    fi

    ((puppet_runs++))
    ((puppet_tries--))

    if [ "$puppet_runs" -eq "$FAILPOINT" ]; then
      echo "Too many Puppet run failures, bailing script.  Could just be an exec resource, or... ?"
      exit 1
    fi

    # Get last run status again.  If we're successful, script is done, otherwise, sleep it off.
    puppetrun_status=$( get_pupstatus )
    if [ "$puppetrun_status" != "unchanged" ]; then
      sleep $SLEEPTIME
    else
      echo "Puppet run successful."
      exit 0
    fi

  done

}

main "$@"
