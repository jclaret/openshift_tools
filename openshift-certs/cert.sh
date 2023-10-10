#!/bin/bash

# Default options
show_all=false
show_expiring=false
object_type="secrets"

# Function to display help message
display_help() {
    echo "Usage: $0 [OPTION]..."
    echo "List and provide basic information about certificates stored in OpenShift objects."
    echo
    echo "Options:"
    echo "  --all                      Show all certificates."
    echo "  --expiring                 Show only certificates expiring in the next 48 hours."
    echo "  --type <object_type>       Specify the type of object to inspect (secrets or configmaps)."
    echo "  --help                     Display this help message."
    echo
    echo "Sample Commands:"
    echo "  Show all certificates in secrets:"
    echo "    $0 --all --type secret"
    echo
    echo "  Show all certificates in configmaps:"
    echo "    $0 --all --type configmap"
    echo
    echo "  Show certificates in secrets expiring within 48 hours:"
    echo "    $0 --expiring --type secret"
    echo
    echo "  Show certificates in configmaps expiring within 48 hours:"
    echo "    $0 --expiring --type configmap"
}

# Show help by default if no arguments are provided
if [[ $# -eq 0 ]]; then
    display_help
    exit 0
fi

# Parse options
while :; do
    case $1 in
        --all) show_all=true ;;
        --expiring) show_expiring=true ;;
        --type) 
            if [[ -n $2 ]]; then
                object_type=$2
                shift
            else
                echo "Error: --type requires an argument."
                exit 1
            fi
        ;;
        --help) display_help; exit 0 ;;
        --) shift; break ;;
        -?*) echo "Unknown option: $1"; exit 1 ;;
        *) break ;;
    esac
    shift
done

# Function to print certificate info
print_info() {
    local namespace=$1
    local name=$2
    local cert=$3
    local kind=$4
    local expiry_date

    expiry_date=$(echo $cert | base64 -d | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [[ -z $expiry_date ]]; then
        return
    fi

    local current_date=$(date -u "+%b %d %H:%M:%S %Y %Z")
    local expiry_timestamp=$(date -d "$expiry_date" +%s)
    local current_timestamp=$(date -d "$current_date" +%s)
    local forty_eight_hours_from_now=$(( $current_timestamp + 2*24*60*60 ))

    if $show_expiring && (( $expiry_timestamp > $forty_eight_hours_from_now )); then
        return
    fi

    local color_reset="\e[0m"
    local color_namespace="\e[36m"  # Cyan
    local color_name="\e[32m"  # Green
    local color_expiry

    if (( $expiry_timestamp < $forty_eight_hours_from_now )); then
        color_expiry="\e[31m"  # Red
    else
        color_expiry="\e[37m"  # White
    fi

    echo -e "${color_namespace}Namespace: ${namespace}${color_reset}"
    echo -e "${color_name}${kind} Name: ${name}${color_reset}"
    echo "-------------------------"
    echo -e "${color_expiry}"
    echo $cert | base64 -d | openssl x509 -noout -issuer -subject -dates
    echo -e "${color_reset}-------------------------"
}

# Function to process secrets
process_secrets() {
    oc get secret -A -o json | jq -r '
      .items |
      sort_by(.metadata.namespace, .metadata.name) |
      .[] |
      select(.data != null) |
      "\(.metadata.namespace) \(.metadata.name) \(.data | to_entries[] | select(.key | test("crt") or test("cert"))| .value)"
    ' | while read namespace name cert; do
        print_info $namespace $name $cert secret
    done
}

# Function to process configmaps
process_configmaps() {
    oc get cm -A -o json | jq -r '
      .items |
      sort_by(.metadata.namespace, .metadata.name) |
      .[] |
      select(.data != null) |
      .metadata.namespace + " " + .metadata.name + " " + (.data | to_entries[] | select(.key | test("crt")) | .value | @base64)
    ' | while read -r namespace name cert_base64; do
        print_info $namespace $name "$cert_base64" configmap
    done
}

# Determine which object type to process
case $object_type in
    "secret") process_secrets ;;
    "configmap") process_configmaps ;;
    *) echo "Unknown object type: $object_type"; exit 1 ;;
esac
