resource "random_password" "authentik_bootstrap_token" {
  length  = 48
  special = false
}

provider "authentik" {
  url   = "${var.authentik_endpoint_protocol}://${var.authentik_endpoint_domain}"
  token = random_password.authentik_bootstrap_token.result
}

resource "kubernetes_config_map" "authentik_assets" {
  depends_on = [kubernetes_namespace.nextit]
  metadata {
    name      = "authentik-assets"
    namespace = var.k8s_namespace
  }

  binary_data = {
    "logo.png"    = "${filebase64("assets/logo.png")}"
    "favicon.ico" = "${filebase64("assets/favicon.ico")}"
    # "background.jpg" = "${filebase64("assets/background.jpg")}"
  }
}

resource "helm_release" "authentik" {
  depends_on = [kubernetes_config_map.authentik_assets, kubernetes_namespace.nextit]
  name       = "authentik"
  repository = "https://charts.goauthentik.io"
  chart      = "authentik"
  namespace  = var.k8s_namespace
  version    = "2023.10.6"

  values = [
    file("authentik-helm-values.yaml"),
  ]

  set {
    name  = "service.type"
    value = var.test_setup ? "NodePort" : "ClusterIP"
  }

  set {
    name  = "service.nodePort"
    value = "30123"
  }

  set {
    name  = "redis.enabled"
    value = "true"
  }

  set {
    name  = "env.AUTHENTIK_BOOTSTRAP_PASSWORD"
    value = var.authentik_bootstrap_password
  }

  set {
    name  = "env.AUTHENTIK_BOOTSTRAP_TOKEN"
    value = random_password.authentik_bootstrap_token.result
  }

  set {
    name  = "ingress.enabled"
    value = var.test_setup ? "false" : "true"
  }

  set {
    name  = "ingress.hosts[0].host"
    value = var.traefik_authentik_domain
  }

  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
  }

  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = var.traefik_authentik_domain
  }

  set {
    name  = "ingress.tls[0].secretName"
    value = "nextitcloud-tls"
  }
}

resource "time_sleep" "wait_5min_for_dns_and_certificate" {
  depends_on = [helm_release.authentik]

  create_duration = var.test_setup ? "0s" : "180s"
}

# ----------------------------------------
# AUTHENTIK
# ----------------------------------------

# AUTHENTICATION FLOW
data "authentik_flow" "default-authorization-flow" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  slug       = "default-provider-authorization-explicit-consent"
}

resource "authentik_application" "nextjs-web" {
  name              = "Next-IT Dashboard"
  slug              = "nextit"
  protocol_provider = authentik_provider_oauth2.nextjs_web.id
}

resource "authentik_flow" "nextit-login-flow" {
  depends_on  = [time_sleep.wait_5min_for_dns_and_certificate]
  slug        = "nextit-login"
  name        = "NextIT"
  designation = "authentication"
  title       = "Anmelden bei NextIT"
  # background  = "/assets/background.jpg"
}

data "authentik_stage" "default-authentication-identification" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "default-authentication-identification"
}

resource "authentik_flow_stage_binding" "login-1" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-login-flow.uuid
  stage      = data.authentik_stage.default-authentication-identification.id
  order      = 10
}

data "authentik_stage" "default-authentication-password" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "default-authentication-password"
}

resource "authentik_flow_stage_binding" "login-2" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-login-flow.uuid
  stage      = data.authentik_stage.default-authentication-password.id
  order      = 20
}

resource "authentik_policy_expression" "flow-password-policy" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "nextit-flow-password-policy"
  expression = <<EOT
flow_plan = request.context.get("flow_plan")
if not flow_plan:
    return True
return not hasattr(flow_plan.context.get("pending_user"), "backend")
EOT
}

resource "authentik_policy_binding" "flow-password-policy" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow_stage_binding.login-2.id
  policy     = authentik_policy_expression.flow-password-policy.id
  order      = 0
}

data "authentik_stage" "default-authentication-mfa-validation" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "default-authenticator-totp-setup"
}

resource "authentik_stage_authenticator_validate" "mfa-validation" {
  count = var.disable_2fa ? 0 : 1

  depends_on            = [time_sleep.wait_5min_for_dns_and_certificate]
  name                  = "mfa-validation"
  device_classes        = ["totp"]
  not_configured_action = "configure"
  configuration_stages  = [data.authentik_stage.default-authentication-mfa-validation.id]
}

resource "authentik_flow_stage_binding" "login-3" {
  count = var.disable_2fa ? 0 : 1

  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-login-flow.uuid
  stage      = authentik_stage_authenticator_validate.mfa-validation.0.id
  order      = 30
}

resource "authentik_stage_user_login" "user_login" {
  depends_on         = [time_sleep.wait_5min_for_dns_and_certificate]
  name               = "nextit_user_login_stage"
  remember_me_offset = "days=30"
}

resource "authentik_flow_stage_binding" "login-4" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-login-flow.uuid
  stage      = authentik_stage_user_login.user_login.id
  order      = 40
}

# ENROLLMENT FLOW SETUP
resource "authentik_flow" "nextit-enrollment-flow" {
  depends_on  = [time_sleep.wait_5min_for_dns_and_certificate]
  name        = "mfa-signup"
  slug        = "nextit-signup"
  title       = "NextIT-Registrierung"
  designation = "enrollment"
}

resource "authentik_stage_invitation" "invitation" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "nextit-invitation"
}

resource "authentik_flow_stage_binding" "signup-1" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_invitation.invitation.id
  order      = 10
}

resource "authentik_stage_prompt_field" "username" {
  depends_on  = [time_sleep.wait_5min_for_dns_and_certificate]
  name        = "nextit-enrollment-username"
  label       = "Username"
  type        = "username"
  required    = true
  placeholder = "Username"
  field_key   = "username"
  order       = 0
}

resource "authentik_stage_prompt_field" "password" {
  depends_on  = [time_sleep.wait_5min_for_dns_and_certificate]
  name        = "nextit-enrollment-password"
  label       = "Password"
  type        = "password"
  required    = true
  placeholder = "Password"
  field_key   = "password"
  order       = 300
}

resource "authentik_stage_prompt_field" "password-repeat" {
  depends_on  = [time_sleep.wait_5min_for_dns_and_certificate]
  name        = "nextit-enrollment-password-repeat"
  label       = "Password (Bestätigung)"
  type        = "password"
  required    = true
  placeholder = "Password (Bestätigung)"
  field_key   = "password_repeat"
  order       = 301
}

resource "authentik_stage_prompt" "signup-2" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "nextit-username-password-repeated"
  fields = [
    authentik_stage_prompt_field.username.id,
    authentik_stage_prompt_field.password.id,
    authentik_stage_prompt_field.password-repeat.id,
  ]
}

resource "authentik_flow_stage_binding" "signup-2" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_prompt.signup-2.id
  order      = 20
}

resource "authentik_stage_prompt_field" "name" {
  depends_on  = [time_sleep.wait_5min_for_dns_and_certificate]
  name        = "nextit-enrollment-name"
  label       = "Vor- und Nachname"
  type        = "text"
  required    = true
  placeholder = "Vor- und Nachname"
  field_key   = "name"
  order       = 0
}

resource "authentik_stage_prompt_field" "email" {
  depends_on  = [time_sleep.wait_5min_for_dns_and_certificate]
  name        = "nextit-enrollment-email"
  label       = "E-Mail"
  type        = "email"
  required    = true
  placeholder = "E-Mail"
  field_key   = "email"
  order       = 1
}

resource "authentik_stage_prompt" "signup-3" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "nextit-name-email"
  fields = [
    authentik_stage_prompt_field.name.id,
    authentik_stage_prompt_field.email.id,
  ]
}

resource "authentik_flow_stage_binding" "signup-3" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_prompt.signup-3.id
  order      = 30
}

resource "authentik_group" "customers" {
  depends_on   = [time_sleep.wait_5min_for_dns_and_certificate]
  name         = "customers"
  is_superuser = false
}

resource "authentik_stage_user_write" "signup-4" {
  depends_on               = [time_sleep.wait_5min_for_dns_and_certificate]
  name                     = "user-write"
  create_users_as_inactive = false
  user_creation_mode       = "always_create"
  create_users_group       = authentik_group.customers.id
}

resource "authentik_flow_stage_binding" "signup-4" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_user_write.signup-4.id
  order      = 40
}

data "authentik_flow" "totp-setup" {
  count      = var.disable_2fa ? 0 : 1
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  slug       = "default-authenticator-totp-setup"
}

resource "authentik_stage_authenticator_totp" "signup-5" {
  count          = var.disable_2fa ? 0 : 1
  depends_on     = [time_sleep.wait_5min_for_dns_and_certificate]
  name           = "nextit_totp"
  friendly_name  = "NextIT"
  configure_flow = data.authentik_flow.totp-setup.0.id
}

resource "authentik_flow_stage_binding" "signup-5" {
  count      = var.disable_2fa ? 0 : 1
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_authenticator_totp.signup-5.0.id
  order      = 50
}

resource "authentik_flow_stage_binding" "signup-6" {
  count      = var.disable_2fa ? 0 : 1
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_user_write.signup-4.id
  order      = 60
}

resource "authentik_flow_stage_binding" "signup-7" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  target     = authentik_flow.nextit-enrollment-flow.uuid
  stage      = authentik_stage_user_login.user_login.id
  order      = 70
}

# PROVIDER & APPLICATION

data "authentik_scope_mapping" "oauth" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-openid"
  ]
}

data "authentik_certificate_key_pair" "default" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "authentik Self-signed Certificate"
}

resource "authentik_provider_oauth2" "nextjs_web" {
  depends_on          = [time_sleep.wait_5min_for_dns_and_certificate]
  name                = "nextit"
  client_id           = var.authentik_nextit_clientid
  client_secret       = var.authentik_nextit_clientsecret
  authentication_flow = authentik_flow.nextit-login-flow.uuid
  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  property_mappings   = data.authentik_scope_mapping.oauth.ids
  signing_key         = data.authentik_certificate_key_pair.default.id
}

resource "authentik_tenant" "default" {
  depends_on          = [time_sleep.wait_5min_for_dns_and_certificate]
  domain              = var.authentik_endpoint_domain
  flow_authentication = authentik_flow.nextit-login-flow.uuid
  branding_title      = "NextIT"
  branding_logo       = "/media/assets/logo.png"
  branding_favicon    = "/media/assets/favicon.ico"
}

data "authentik_group" "admins" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  name       = "authentik Admins"
}

resource "authentik_user" "name" {
  depends_on = [time_sleep.wait_5min_for_dns_and_certificate]
  username   = var.authentik_username
  name       = var.authentik_name
  password   = var.authentik_password
  groups     = [data.authentik_group.admins.id]
}
