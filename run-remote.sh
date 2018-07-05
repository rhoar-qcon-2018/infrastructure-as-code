#!/bin/bash

# Uncomment for debugging
#set -x
#set -e

if [[ "${OPENSHIFT_USERNAME}X" == "X" ]]; then
    printf "Enter your OpenShift user ID: "
    read username
    echo ${username} | grep "^user[0-9]*$"
    if [[ $? -eq 0 ]]; then
        printf "Exporting OPENSHIFT_USERNAME\n"
        export OPENSHIFT_USERNAME="${username}"
        echo "VALUE: ${OPENSHIFT_USERNAME}"
    else
        echo "Invalid username"
    fi
fi

if [[ "${OPENSHIFT_USERNAME}X" != "X" ]]; then

    oc login -u ${OPENSHIFT_USERNAME} -p "r3dh4t1!" --insecure-skip-tls-verify=true https://master.qcon.openshift.opentlc.com/

    DOCKER_COMMAND="docker run -v $HOME/.kube/config:/openshift-applier/.kube/config:z -w /tmp/my-inventory -u root -v $PWD:/tmp/my-inventory -e INVENTORY_PATH=/tmp/my-inventory -t redhatcop/openshift-applier"

    ${DOCKER_COMMAND} ./clean-unique-names.sh

    ${DOCKER_COMMAND} ansible-galaxy install -r requirements.yml --roles-path=roles

    ${DOCKER_COMMAND} ansible-playbook unique-projects-playbook.yaml -i inventory/ -e "project_name_postfix=${OPENSHIFT_USERNAME}" -e target=bootstrap

    ${DOCKER_COMMAND} ansible-playbook unique-projects-playbook.yaml -i inventory/ -e "project_name_postfix=${OPENSHIFT_USERNAME}" -e target=tools

    ${DOCKER_COMMAND} ansible-playbook unique-projects-playbook.yaml -i inventory/ -e "project_name_postfix=${OPENSHIFT_USERNAME}" -e target=apps

fi