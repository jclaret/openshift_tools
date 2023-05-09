#!/bin/bash

# Setting 'set -e' to stop the script if any command fails
set -e

# Function to handle errors
error_exit() {
  echo "$1" >&2
  exit "${2:-1}"
}

# Crafting an ImageSet with designated minimum and maximum Openshift versions
cat << EOF > imageset-config.yaml
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
storageConfig:
  registry:
    imageURL: $QUAY_HOSTNAME/openshift4
    skipTLS: false
mirror:
  platform:
    channels:
    - name: stable-4.12
      minVersion: 4.12.9
      maxVersion: 4.12.10
      type: ocp
EOF

# Checking for any error while creating ImageSet
if [ $? -ne 0 ]; then
  error_exit "Failed to create ImageSet. Please check your configurations."
fi

echo "Successfully crafted the ImageSet. Proceeding to the mirroring phase, which might take some time."

# Export PATH
export PATH=$PATH:.

# Commencing the mirroring of the OpenShift release
chmod 755 oc-mirror
oc-mirror --config=./imageset-config.yaml docker://$QUAY_HOSTNAME/openshift4

# Checking for any error during the mirroring process
if [ $? -ne 0 ]; then
  error_exit "Failed to mirror the OpenShift release. Please check your network connection or configurations."
fi

echo "Mirroring process completed. Now, let's generate the necessary authentication file."

# Generating the auth.json authentication file
AUTH=$(echo -n "${QUAY_USER}:${QUAY_PASSWORD}" | base64 -w0) || error_exit "Failed to encode credentials."
cat << EOF > auth.json
{"auths":{"$QUAY_HOSTNAME":{"auth":"$AUTH"}}}
EOF

# Checking for any error while creating the authentication file
if [ $? -ne 0 ]; then
  error_exit "Failed to create the authentication file. Please check your credentials."
fi

echo "Authentication file successfully generated and ready for use."
