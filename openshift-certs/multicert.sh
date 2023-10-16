#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: $0 [FILE]"
    echo "Display issuer and validity period of all certificates in the specified file."
    echo
    echo "Example:"
    echo "  $0 yourfile.pem"
}

# Check if a file name is provided
if [[ $# -eq 0 ]]; then
    display_help
    exit 0
fi

# Get the file name from the command line arguments
file=$1

# Split the file into individual certificates
csplit -f cert- "$file" '/-----BEGIN CERTIFICATE-----/' '{*}'

# Remove the unwanted file
rm cert-00

# Loop through the certificate files and process them
for certfile in cert-*; do
    echo "-----"
    echo -n "Issuer: " && openssl x509 -in $certfile -noout -issuer
    echo -n "Not Before: " && openssl x509 -in $certfile -noout -startdate
    echo -n "Not After: " && openssl x509 -in $certfile -noout -enddate
done

# Optionally, clean up the individual certificate files
rm cert-*

