#!/usr/local/bin/bash

# This file installs the accompanying `check_mk_agent.freebsd` file 
# in a given system running FreeBSD and takes measures that the script
# will run as a service on system reboot.
# This is basically an implementation of the instruction found at
# `https://checkmk.de/cms_legacy_freebsd.html`

set -o xtrace

inject_into_file() {
    presence=$1
    expected=$2
    file=$3

    if [ "$(grep -c ^$expected$ $file)" -eq 0 ]
    then
        # easy case: the config we have are looking for is not there,
        # so we simply add it to the end of the file
        if [ "$(grep -c ^$presence.*$ $file)" -eq 0 ]; then
            echo $expected >> $file
            return
        # the config is present, but we can simply replace it
        elif [ "$(grep -c ^$presence.*$ $file)" -eq 1 ]; then
            sed -i 's|"^$presence.*$"|"$expected"|' $file
            return
        # no decision can be made on how to progress
        else
            echo "Can't decide on what to do in file '$file' for exptected '$expected', "\
                "since multiple occurances of presence checker '$presence' has been found."
            exit 1
        fi
    fi

    # TODO: are multiple occurances of $expected an edge case?
}

if [ $# -ne 2 ]; then
    echo "Wrong number of arguments"
    echo "usage: $0 <check-mk-ip> <freebsd-agent-file>"
    exit 1
fi

CHECK_MK_IP=$1
AGENT_FILE=$2

cp $AGENT_FILE /usr/local/bin/check_mk_agent
chmod +x $AGENT_FILE

inject_into_file "inetd_enable=" "inetd_enable=yes" /etc/rc.conf
inject_into_file "inetd_flags=" "inetd_flags=-wW" /etc/rc.conf

inject_into_file "check_mk " "check_mk 6556/tcp #check_mk agent" /etc/services

inject_into_file "check_mk " "check_mk stream tcp nowait root /usr/local/bin/check_mk_agent check_mk_agent" /etc/inetd.conf

inject_into_file "check_mk_agent : $CHECK_MK_IP" "check_mk_agent : $CHECK_MK_IP : allow" /etc/hosts.allow
inject_into_file "check_mk_agent : ALL" "check_mk_agent : ALL : deny" /etc/hosts.allow

/etc/rc.d/inetd start
if [ $? -ne 0 ]; then
    /etc/rc.d/inetd restart
fi
