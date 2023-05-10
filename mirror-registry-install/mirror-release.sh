#!/bin/bash

# Stop the script if any command fails
set -e

# Function to handle errors
error_exit() {
  echo "$1" >&2
  exit "${2:-1}"
}

# Ensure necessary environment variables are set
if [[ -z "${QUAY_HOSTNAME}" ]] || [[ -z "${QUAY_USER}" ]] || [[ -z "${QUAY_PASSWORD}" ]]; then
  error_exit "One or more required environment variables (QUAY_HOSTNAME, QUAY_USER, QUAY_PASSWORD) are not set. Please check your settings."
fi

# Export PATH
export PATH=$PATH:.

# Crafting an ImageSet with designated minimum and maximum Openshift versions
echo "Creating ImageSet configuration..."
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

# Generating the auth.json authentication file
echo "Generating authentication file..."
AUTH=$(echo -n "${QUAY_USER}:${QUAY_PASSWORD}" | base64 -w0) || error_exit "Failed to encode credentials."
cat << EOF > auth.json
{"auths":{"$QUAY_HOSTNAME":{"auth":"$AUTH"}}}
EOF

# Ensure the Docker configuration directory exists
mkdir -p ~/.docker

# Merge pull-secret.json and auth.json, then output to Docker's config.json
if jq -s '.[0] * .[1]' pull-secret.json auth.json > ~/.docker/config.json; then
    echo "Successfully merged pull-secret.json and auth.json into Docker's config.json."
else
    error_exit "Failed to merge pull-secret.json and auth.json files."
fi

echo "Authentication file successfully generated and ready for use."

# Commencing the mirroring of the OpenShift release
echo "Starting the mirroring process. This may take a while..."
chmod 755 oc-mirror
./oc-mirror --config=./imageset-config.yaml docker://$QUAY_HOSTNAME/openshift4 || error_exit "Failed to mirror the OpenShift release. Please check your network connection or configurations."

echo "Mirroring process completed successfully."
