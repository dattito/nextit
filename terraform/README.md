# Test Setup With Terraform + Kind Cluster

## Install Requirements

Make sure that Terraform and Kind are installed:

```
brew install terraform kind
```

## Start/Delete the Development Setup

The setup can be started with

```
terraform apply --auto-approve
```

and deleted with

```
terraform destroy --auto-approve
```

Terraform will spin up a Kind Cluster and installs Authentik and other services in it.

## Enter and Explore Authentik

Authentik will be availabe at `http://localhost:9000`.
