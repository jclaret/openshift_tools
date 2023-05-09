#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if wget and tar are installed
command -v wget >/dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Aborting."; exit 1; }
command -v tar >/dev/null 2>&1 || { echo >&2 "I require tar but it's not installed. Aborting."; exit 1; }

# Define URLs
MIRROR_REGISTRY_URL="https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz"
OC_MIRROR_URL="https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/oc-mirror.tar.gz"
OC_CLIENT_URL="https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz"

# Download and extract files
wget -qO- "$MIRROR_REGISTRY_URL" | tar xz
wget -qO- "$OC_MIRROR_URL" | tar xz
wget -qO- "$OC_CLIENT_URL" | tar xz

# Check if required variables are set
if [[ -z "$QUAY_HOSTNAME" || -z "$QUAY_ROOT" || -z "$QUAY_USER" || -z "$QUAY_PASSWORD" ]]; then
    echo "One or more required variables are not set. Please set QUAY_HOSTNAME, QUAY_ROOT, QUAY_USER, and QUAY_PASSWORD."
    exit 1
fi

# Mirror install
mirror-registry install --quayHostname ${QUAY_HOSTNAME} --quayRoot ${QUAY_ROOT} --initUser ${QUAY_USER} --initPassword ${QUAY_PASSWORD}

# Check if mirror-registry completed successfully
if [ $? -eq 0 ]; then
    echo "mirror-registry completed without errors"
else
    echo "mirror-registry encountered an error"
    exit 1
fi
