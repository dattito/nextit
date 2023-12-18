# Test Setup With Terraform + Kind Cluster

## Install Requirements

Make sure that Terraform and Kind are installed:

```
brew install hashicorp/tap/terraform kind
```

In the `nextit/terraform` directory, execute

```
terraform init
```

to install the required terraform dependencies

## Start the Development Setup

The setup can be started with

```
terraform apply --auto-approve
```

The setup takes around 4 Minutes, at the first run longer.
Terraform will spin up a Kind Cluster and installs Authentik and other services in it.

## Enter and Explore Authentik

Authentik will be availabe at `http://localhost:9000`.

Credentials (for now):

- username: `akadmin`
- password: `1234`

## Delete the Development Setup

Delete the setup with

```
terraform destroy --auto-approve
```
