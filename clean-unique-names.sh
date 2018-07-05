#!/bin/bash

## Remove any user-specific settings from the inventory
egrep -r "user[0-9]*" params/* | awk -F":" '{print $1}' | sort | uniq | grep -v openshift-template | xargs -r -n 1 sed -i 's@ (user[0-9]*)$@@g'
egrep -r "user[0-9]*" params/* | awk -F":" '{print $1}' | sort | uniq | grep -v openshift-template | xargs -r -n 1 sed -i 's@user[0-9]*$@@g'