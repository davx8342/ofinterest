#!/bin/bash

#
# files module
#

source ${1}

hostname="${2}"
ip="${3}"

echo "- Files module for ${hostname}"

#
# on first run, or if we have a new host, we need to create a 
# directory to store files to diff and diff history
#
if [ ! -d "${VARPATH}/${hostname}" ]; then
  echo - host ${hostname} is new
  mkdir "${VARPATH}/${hostname}"
fi

#
# here we step through the files we're monitoring for changes
#
for file in `cat ${ETCPATH}/files`; do

  #
  # before we start, lets actually check the remote host
  # has the file we want to check, if it doesn't then we
  # skip out to the next file
  #
  if ssh -q -i ${SSHKEY} ${SSHUSER}@${ip} stat ${file}\> /dev/null 2\>\&1; then

    #
    # remote file exists, lets do some work
    #
    datestamp=`date +%Y%m%d%H%M` 
    NEWFILE="no"
    filename=$(basename ${file})
    stripslash=`echo $file|sed -e "s/^\///"`
    dirpath=`echo $file|sed -e "s/^\///"|sed -e "s/${filename}//"`

    if [ ! -d "${VARPATH}/${hostname}/${dirpath}" ]; then
      echo "- making ${VARPATH}/${hostname}/${dirpath}"
      mkdir -p ${VARPATH}/${hostname}/${dirpath}
    fi

    if [ ! -f "${VARPATH}/${hostname}/${stripslash}" ]; then
      NEWFILE="yes"
      echo "- ${file} is new"
      scp -i ${SSHKEY} ${SSHUSER}@${ip}:${file} ${VARPATH}/${hostname}/${stripslash}
    else
      local_ck=`cksum ${VARPATH}/${hostname}/${stripslash}`
      remote_ck=`ssh -i ${SSHKEY} ${SSHUSER}@${ip} -C "cksum ${file}"`
      remote_ck_vars=( ${remote_ck} )
      remote_bytes=${remote_ck_vars[1]}
      remote_cksum=${remote_ck_vars[0]}
      local_ck_vars=( ${local_ck} )
      local_bytes=${local_ck_vars[1]}
      local_cksum=${local_ck_vars[0]}
      echo ${hostname} ${file} ${local_cksum} ${remote_cksum}

      #
      # if the cksum doesn't match, then something has changed and we run a diff
      #
      if [ "${remote_cksum}" != "${local_cksum}" ]; then
        echo "- $file has changed"
        scp -i ${SSHKEY} ${SSHUSER}@${ip}:${file} ${VARPATH}/${hostname}/${stripslash}.new
        diff -c ${VARPATH}/${hostname}/${stripslash} ${VARPATH}/${hostname}/${stripslash}.new > ${VARPATH}/${hostname}/${dirpath}/${datestamp}.${filename}.diff
        echo "- diff saved to ${VARPATH}/${hostname}/${dirpath}/${datestamp}.${filename}.diff"
        rm ${VARPATH}/${hostname}/${stripslash}
        mv ${VARPATH}/${hostname}/${stripslash}.new ${VARPATH}/${hostname}/${stripslash}

        #
        # if defined, we email out the diff
        #
        if [ "${EMAILADDRESS}" ]; then
          mail -s "${hostname} diff found in ${file}" ${EMAILADDRESS} < ${VARPATH}/${hostname}/${dirpath}/${datestamp}.${filename}.diff
        fi
      fi
    fi
  fi
done

