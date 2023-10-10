# OpenShift Certificate Inspector

This script is designed to provide an overview of the certificates stored in OpenShift objects. It supports inspecting both secrets and configmaps, and can filter results to show all certificates or only those that are expiring within the next 48 hours.

## Dependencies

* [OpenShift CLI (oc)](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html)
* [jq](https://stedolan.github.io/jq/download/) for JSON processing
* [openssl](https://www.openssl.org/source/) for certificate processing

## Usage

```bash
cert.sh [OPTION]
```

## Options

```
--all: Show all certificates.
--expiring: Show only certificates expiring in the next 48 hours.
--type <object_type>: Specify the type of object to inspect (secret or configmap).
--help: Display help message.
```

## Sample Commands
* Show all certificates in secrets:
```
cert.sh --all --type secret
```

* Show all certificates in configmaps:
```
cert.sh --all --type configmap
```

* Show certificates in secrets expiring within 48 hours:
```
cert.sh --expiring --type secret
```

* Show certificates in configmaps expiring within 48 hours:
```
cert.sh --expiring --type configmap
```
