# Test Setup With Terraform + Kind Cluster

## Install Requirements

Make sure that **Terraform** and **Kind** are installed:

```
brew install hashicorp/tap/terraform kind
```

In the `nextit/terraform` directory (where all the .tf files are), execute

```
terraform init
```

to install the required terraform dependencies

## Start the Development / Local Setup

The setup can be started with

```
terraform apply --auto-approve
```

The setup takes a few minutes.
Terraform will spin up a Kind Cluster and installs Authentik and other services in it.

## Enter and Explore Authentik

⚠️ Two Factor Authentication is disabled by default for testing purposes! To enable it, go to `testing.auto.tfvars` and change `disable_2fa` from true to false. This has to be made before login

Authentik will be availabe at `http://localhost:9000`.

Credentials:

- username: `akadmin`
- password: `1234`

## Delete the Development Setup

Delete the setup with

```
terraform destroy --auto-approve
```
