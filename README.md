# nextit | A university project

This repository was created within a university project at DHBW Mannheim.

The focus on this project was to show the functionality of microservices
and 2fa authentication. Everything that gets deployed is written in terraform files
and can be executed yourself locally or in the cloud. It leverages Authentik for authentication,
external-dns for DNS records, cert-manager for ssl certificates, NextJS for the frontend,
some Rust with gRPC in the backend and postgres as the database.

You can login and add some posts and see the posts of other users.

## Run It Locally

### 1. Terraform Development Setup

Follow the steps of the `README.md` in the `terraform` directory

### 2. Run The Webserver

1. Go into the `web` directory
2. Execute `npm i`
3. Execute `npm run dev`
4. Visit `http://localhost:3000`
