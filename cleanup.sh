#!/usr/bin/env bash

minishift status | grep "Running" && export IS_MINISHIFT="X" || export IS_MINISHIFT="Y"

if [[ "${IS_MINISHIFT}" == "X" ]]; then
    minishift delete -f
else
    oc get projects | grep "^labs.*" | awk '{print $1}' | xargs -n 1 oc delete project
fi