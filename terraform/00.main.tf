terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "0.2.1"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.10.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

variable "authentik_bootstrap_password" {
  type      = string
  sensitive = true
}

variable "authentik_nextit_clientid" {
  type      = string
  sensitive = true
}

variable "authentik_nextit_clientsecret" {
  type      = string
  sensitive = true
}

variable "authentik_endpoint_domain" {
  type = string
}

variable "authentik_endpoint_protocol" {
  type    = string
  default = "https"
}

variable "web_postgres_password" {
  type      = string
  sensitive = true
}

variable "test_setup" {
  type    = bool
  default = true
}

variable "acme_email" {
  type = string
}

variable "traefik_authentik_domain" {
  type = string
}

variable "platform" {
  default = "arm"
}
