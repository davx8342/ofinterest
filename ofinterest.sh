#!/bin/bash

#
# we take one argument, and that is our config file
#
if [ ! -f "$1" ]; then
  echo "usage: $0 <config file>"
  exit 0
fi

#
# source our config file
#
source $1

#
# of course, just because we have a config file doesn't mean it contains
# everything we want, these are show stoppers which we need to trap
#
if [ ! "${VARPATH}" ] || [ ! "${ETCPATH}" ] || [ ! "${SSHKEY}" ]; then
  echo "ERROR: VARPATH or ETCPATH or SSHKEY are not set."
  exit 1
fi

if [ ! -f "${ETCPATH}/hosts" ]; then
  echo "ERROR: no hosts file found in ${ETCPATH}"
  exit 1
fi

if [ ! -f "${SSHKEY}" ]; then
  echo "ERROR: ${SSHKEY} does not exist."
  exit 1
fi


#
# change our separator to be new lines 
#
IFS=$'\n'


#
# step through our hosts file, and run our modules per host
#
for line in `cat ${ETCPATH}/hosts`; do
  unset IFS
  host_vars=( ${line} )
  hostname=${host_vars[0]}
  ip=${host_vars[1]}
  echo "Processing ${hostname}"

  #
  # will change this to per host modules, but global right now
  #
  ${ROOTPATH}/modules/files.sh ${1} ${hostname} ${ip}

done

