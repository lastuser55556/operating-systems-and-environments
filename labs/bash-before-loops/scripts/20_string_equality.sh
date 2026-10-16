#!/bin/bash
user="$(whoami)"
if [ "$user" = "$(whoami)" ]
then
    echo "The user $user is the current logged in user"
fi
