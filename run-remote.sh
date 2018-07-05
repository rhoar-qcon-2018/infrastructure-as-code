#!/bin/bash

# Uncomment for debugging
#set -x
#set -e

DOCKER_CMD_PREFIX=""

if [[ "${OPENSHIFT_USERNAME}X" == "X" || "${OPENSHIFT_PASSWORD}X" == "X" ]]; then
    printf "Enter your OpenShift user ID: "
    read OPENSHIFT_USERNAME
    printf "Enter your OpenShift Password: "
    read -s OPENSHIFT_PASSWORD
    echo
fi

if [[ "${OPENSHIFT_URL}X" == "X" ]]; then
    printf 'Enter the URL for the OpenShift console: '
    read OPENSHIFT_URL
fi

ansible --version | grep "^ansible 2\.[56].*"
ANSIBLE_STATUS=$?

if [[ $ANSIBLE_STATUS -eq 0 ]]; then
    echo "Ansible version is acceptable"
else
    echo "Ansible is either missing or too old. Attempting to use containerized Ansible."
    docker ps
    DOCKER_STATUS=$?
    if [[ $DOCKER_STATUS -eq 0 ]]; then
        DOCKER_CMD_PREFIX="docker run -v $HOME/.kube/config:/openshift-applier/.kube/config:z -w /tmp/my-inventory -u root -v $PWD:/tmp/my-inventory -e INVENTORY_PATH=/tmp/my-inventory -t redhatcop/openshift-applier"
    else
        echo "Ansible version missing/unacceptable, and containerized Ansible is not possible. If you are running on Windows, try installing the Windows Subsystem For Linux (WSL) from the store and try from the Bash terminal there."
        echo 1
    fi
fi

if [[ "${OPENSHIFT_USERNAME}X" != "X" ]]; then

    oc login -u ${OPENSHIFT_USERNAME} -p "${OPENSHIFT_PASSWORD}" --insecure-skip-tls-verify=true ${OPENSHIFT_URL}

    ${DOCKER_CMD_PREFIX} ./clean-unique-names.sh

    ${DOCKER_CMD_PREFIX} ansible-galaxy install -r requirements.yml --roles-path=roles

    ${DOCKER_CMD_PREFIX} ansible-playbook unique-projects-playbook.yaml -i inventory/ -e "project_name_postfix=${OPENSHIFT_USERNAME}" -e target=bootstrap

    ${DOCKER_CMD_PREFIX} ansible-playbook unique-projects-playbook.yaml -i inventory/ -e "project_name_postfix=${OPENSHIFT_USERNAME}" -e target=tools

    ${DOCKER_CMD_PREFIX} ansible-playbook unique-projects-playbook.yaml -i inventory/ -e "project_name_postfix=${OPENSHIFT_USERNAME}" -e target=apps

fi