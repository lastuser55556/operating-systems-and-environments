#!/bin/bash
user=anotherUser
if grep "^${user}:" /etc/passwd
then
    echo "The user $user Exists"
elif ls /home
then
    echo "The user doesn't exist but /home is present"
fi
