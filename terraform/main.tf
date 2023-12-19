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

resource "kind_cluster" "docker" {
  name = "nextit"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    node {
      role = "control-plane"
      extra_port_mappings {
        container_port = 30123
        host_port      = 9000
        listen_address = "127.0.0.1"
      }
      extra_port_mappings {
        container_port = 30051
        host_port      = 50051
        listen_address = "127.0.0.1"
      }
    }
  }
}

provider "kubernetes" {
  host                   = kind_cluster.docker.endpoint
  client_certificate     = kind_cluster.docker.client_certificate
  client_key             = kind_cluster.docker.client_key
  cluster_ca_certificate = kind_cluster.docker.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.docker.endpoint
    client_certificate     = kind_cluster.docker.client_certificate
    client_key             = kind_cluster.docker.client_key
    cluster_ca_certificate = kind_cluster.docker.cluster_ca_certificate
  }
}

provider "authentik" {
  url   = "${var.authentik_endpoint_protocol}://${var.authentik_endpoint_domain}"
  token = random_password.authentik_bootstrap_token.result
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "default"
  version    = "v1.13.3"
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_config_map" "authentik_assets" {
  metadata {
    name = "authentik-assets"
  }

  binary_data = {
    "logo.png"    = "${filebase64("assets/logo.png")}"
    "favicon.ico" = "${filebase64("assets/favicon.ico")}"
    # "background.jpg" = "${filebase64("assets/background.jpg")}"
  }
}

resource "helm_release" "authentik" {
  depends_on = [kubernetes_config_map.authentik_assets]
  name       = "authentik"
  repository = "https://charts.goauthentik.io"
  chart      = "authentik"
  namespace  = "default"
  version    = "2023.10.4"

  values = [
    file("authentik-helm-values.yaml"),
  ]

  set {
    name  = "env.AUTHENTIK_BOOTSTRAP_PASSWORD"
    value = var.authentik_bootstrap_password
  }

  set {
    name  = "env.AUTHENTIK_BOOTSTRAP_TOKEN"
    value = random_password.authentik_bootstrap_token.result
  }
}

resource "random_password" "authentik_bootstrap_token" {
  length  = 48
  special = true
}

# ----------------------------------------
# AUTHENTIK
# ----------------------------------------

# AUTHENTICATION FLOW
data "authentik_flow" "default-authorization-flow" {
  depends_on = [helm_release.authentik]
  slug       = "default-provider-authorization-explicit-consent"
}

resource "authentik_application" "nextjs-web" {
  name              = "Next-IT Dashboard"
  slug              = "nextit"
  protocol_provider = authentik_provider_oauth2.nextjs_web.id
}

resource "authentik_flow" "nextit-login-flow" {
  depends_on  = [helm_release.authentik]
  slug        = "nextit-login"
  name        = "NextIT"
  designation = "authentication"
  title       = "Anmelden bei NextIT"
  # background  = "/assets/background.jpg"
}

data "authentik_stage" "default-authentication-identification" {
  depends_on = [helm_release.authentik]
  name       = "default-authentication-identification"
}

resource "authentik_flow_stage_binding" "login-1" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-login-flow.uuid
  stage      = data.authentik_stage.default-authentication-identification.id
  order      = 10
}

data "authentik_stage" "default-authentication-password" {
  depends_on = [helm_release.authentik]
  name       = "default-authentication-password"
}

resource "authentik_flow_stage_binding" "login-2" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-login-flow.uuid
  stage      = data.authentik_stage.default-authentication-password.id
  order      = 20
}

resource "authentik_policy_expression" "flow-password-policy" {
  depends_on = [helm_release.authentik]
  name       = "nextit-flow-password-policy"
  expression = <<EOT
flow_plan = request.context.get("flow_plan")
if not flow_plan:
    return True
return not hasattr(flow_plan.context.get("pending_user"), "backend")
EOT
}

resource "authentik_policy_binding" "flow-password-policy" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow_stage_binding.login-2.id
  policy     = authentik_policy_expression.flow-password-policy.id
  order      = 0
}

data "authentik_stage" "default-authentication-mfa-validation" {
  depends_on = [helm_release.authentik]
  name       = "default-authenticator-totp-setup"
}

resource "authentik_stage_authenticator_validate" "mfa-validation" {
  depends_on            = [helm_release.authentik]
  name                  = "mfa-validation"
  device_classes        = ["totp"]
  not_configured_action = "configure"
  configuration_stages  = [data.authentik_stage.default-authentication-mfa-validation.id]
}

resource "authentik_flow_stage_binding" "login-3" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-login-flow.uuid
  stage      = authentik_stage_authenticator_validate.mfa-validation.id
  order      = 30
}

resource "authentik_stage_user_login" "user_login" {
  name               = "nextit_user_login_stage"
  remember_me_offset = "days=30"
}

resource "authentik_flow_stage_binding" "login-4" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-login-flow.uuid
  stage      = authentik_stage_user_login.user_login.id
  order      = 40
}

# ENROLLMENT FLOW SETUP
resource "authentik_flow" "nextit-enrollment-flow" {
  depends_on  = [helm_release.authentik]
  name        = "mfa-signup"
  slug        = "nextit-signup"
  title       = "NextIT-Registrierung"
  designation = "enrollment"
}

resource "authentik_stage_invitation" "invitation" {
  depends_on = [helm_release.authentik]
  name       = "nextit-invitation"
}

resource "authentik_flow_stage_binding" "signup-1" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_invitation.invitation.id
  order      = 10
}

resource "authentik_stage_prompt_field" "username" {
  depends_on  = [helm_release.authentik]
  name        = "nextit-enrollment-username"
  label       = "Username"
  type        = "username"
  required    = true
  placeholder = "Username"
  field_key   = "username"
  order       = 0
}

resource "authentik_stage_prompt_field" "password" {
  depends_on  = [helm_release.authentik]
  name        = "nextit-enrollment-password"
  label       = "Password"
  type        = "password"
  required    = true
  placeholder = "Password"
  field_key   = "password"
  order       = 300
}

resource "authentik_stage_prompt_field" "password-repeat" {
  depends_on  = [helm_release.authentik]
  name        = "nextit-enrollment-password-repeat"
  label       = "Password (Bestätigung)"
  type        = "password"
  required    = true
  placeholder = "Password (Bestätigung)"
  field_key   = "password_repeat"
  order       = 301
}

resource "authentik_stage_prompt" "signup-2" {
  depends_on = [helm_release.authentik]
  name       = "nextit-username-password-repeated"
  fields = [
    authentik_stage_prompt_field.username.id,
    authentik_stage_prompt_field.password.id,
    authentik_stage_prompt_field.password-repeat.id,
  ]
}

resource "authentik_flow_stage_binding" "signup-2" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_prompt.signup-2.id
  order      = 20
}

resource "authentik_stage_prompt_field" "name" {
  depends_on  = [helm_release.authentik]
  name        = "nextit-enrollment-name"
  label       = "Vor- und Nachname"
  type        = "text"
  required    = true
  placeholder = "Vor- und Nachname"
  field_key   = "name"
  order       = 0
}

resource "authentik_stage_prompt_field" "email" {
  depends_on  = [helm_release.authentik]
  name        = "nextit-enrollment-email"
  label       = "E-Mail"
  type        = "email"
  required    = true
  placeholder = "E-Mail"
  field_key   = "email"
  order       = 1
}

resource "authentik_stage_prompt" "signup-3" {
  depends_on = [helm_release.authentik]
  name       = "nextit-name-email"
  fields = [
    authentik_stage_prompt_field.name.id,
    authentik_stage_prompt_field.email.id,
  ]
}

resource "authentik_flow_stage_binding" "signup-3" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_prompt.signup-3.id
  order      = 30
}

resource "authentik_group" "customers" {
  depends_on   = [helm_release.authentik]
  name         = "customers"
  is_superuser = false
}

resource "authentik_stage_user_write" "signup-4" {
  depends_on               = [helm_release.authentik]
  name                     = "user-write"
  create_users_as_inactive = false
  user_creation_mode       = "always_create"
  create_users_group       = authentik_group.customers.id
}

resource "authentik_flow_stage_binding" "signup-4" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_user_write.signup-4.id
  order      = 40
}

data "authentik_flow" "totp-setup" {
  depends_on = [helm_release.authentik]
  slug       = "default-authenticator-totp-setup"
}

resource "authentik_stage_authenticator_totp" "signup-5" {
  depends_on     = [helm_release.authentik]
  name           = "nextit_totp"
  friendly_name  = "NextIT"
  configure_flow = data.authentik_flow.totp-setup.id
}

resource "authentik_flow_stage_binding" "signup-5" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_authenticator_totp.signup-5.id
  order      = 50
}

resource "authentik_flow_stage_binding" "signup-6" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_user_write.signup-4.id
  order      = 60
}

resource "authentik_flow_stage_binding" "signup-7" {
  depends_on = [helm_release.authentik]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_user_login.user_login.id
  order      = 70
}

# PROVIDER & APPLICATION

data "authentik_scope_mapping" "oauth" {
  depends_on = [helm_release.authentik]
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-openid"
  ]
}

data "authentik_certificate_key_pair" "default" {
  depends_on = [helm_release.authentik]
  name       = "authentik Self-signed Certificate"
}

resource "authentik_provider_oauth2" "nextjs_web" {
  depends_on          = [helm_release.authentik]
  name                = "nextit"
  client_id           = var.authentik_nextit_clientid
  client_secret       = var.authentik_nextit_clientsecret
  authentication_flow = authentik_flow.nextit-login-flow.uuid
  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  property_mappings   = data.authentik_scope_mapping.oauth.ids
  signing_key         = data.authentik_certificate_key_pair.default.id
}

resource "authentik_tenant" "default" {
  depends_on          = [helm_release.authentik]
  domain              = var.authentik_endpoint_domain
  flow_authentication = authentik_flow.nextit-login-flow.uuid
  branding_title      = "NextIT"
  branding_logo       = "/media/assets/logo.png"
  branding_favicon    = "/media/assets/favicon.ico"
}
# ----------------------------------------
# ITEM MICROSERVICE
# ----------------------------------------

resource "random_password" "item_microservice_postgres" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "item_microservice_postgres" {
  metadata {
    name = "item-microservice-postgres"
  }

  data = {
    password            = random_password.item_microservice_postgres.result
    "postgres-password" = random_password.item_microservice_postgres.result
  }

  type = "kubernetes.io/basic-auth"
}

resource "helm_release" "item_microservice_postgres" {
  name       = "item-microservice-postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = "default"
  version    = "13.2.24"

  set {
    name  = "auth.username"
    value = "item"
  }

  set {
    name  = "auth.existingSecret"
    value = kubernetes_secret.item_microservice_postgres.metadata[0].name
  }

  set {
    name  = "auth.database"
    value = "item"
  }
}

resource "kubernetes_deployment" "item_microservice" {
  depends_on = [helm_release.item_microservice_postgres]
  metadata {
    name = "item-microservice"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "item-microservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "item-microservice"
        }
      }
      spec {
        container {
          image = "ghcr.io/dattito/nextit/item-microservice:0.2"
          name  = "item-microservice"

          env {
            name = "DATABASE_URL"
            value = "postgres://postgres:${random_password.item_microservice_postgres.result
            }@item-microservice-postgres-postgresql:5432/postgres"
          }

          port {
            container_port = "50051"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "item_microservice" {
  metadata {
    name = "item-microservice"
  }
  spec {
    selector = {
      app = kubernetes_deployment.item_microservice.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 50051
      target_port = 50051
      node_port   = 30051
    }

    type = "NodePort"
  }
}
