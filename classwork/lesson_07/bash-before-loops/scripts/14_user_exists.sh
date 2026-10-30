#!/bin/bash
user=$(whoami)
if grep "^${user}:" /etc/passwd
then
    echo "The user $user Exists"
fi
