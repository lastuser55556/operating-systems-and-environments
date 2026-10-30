#!/bin/bash
val1="Ali"
val2="ali"
if [ "$val1" \> "$val2" ]
then
    echo "$val1 is greater than $val2"
else
    echo "$val1 is less than $val2"
fi
