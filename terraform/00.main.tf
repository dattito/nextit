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
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.10.0"
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

variable "traefik_web_domain" {
  type = string
}

variable "platform" {
  default = "arm"
}

variable "nextauth_secret" {
  sensitive = true
  type      = string
}
