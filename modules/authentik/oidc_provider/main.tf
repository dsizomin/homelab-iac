terraform {
  required_version = ">= 1.6"
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2025.10.0"
    }
  }
}

data "authentik_certificate_key_pair" "certificate" {
  name = "authentik Self-signed Certificate"
}

data "authentik_property_mapping_provider_scope" "oidc_scopes" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}

data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-provider-invalidation-flow"
}

resource "authentik_group" "oidc_group" {
  name = "${var.name}_users"
}

resource "authentik_provider_oauth2" "this" {
  name        = var.name
  client_type = var.client_type
  client_id   = var.client_id
  allowed_redirect_uris = [
    for uri in var.redirect_uris : {
      matching_mode = "strict"
      url           = uri
    }
  ]
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  invalidation_flow  = data.authentik_flow.default_invalidation_flow.id
  property_mappings  = data.authentik_property_mapping_provider_scope.oidc_scopes.ids

  signing_key = data.authentik_certificate_key_pair.certificate.id
}

resource "authentik_application" "application" {
  name              = var.name
  slug              = var.name
  protocol_provider = authentik_provider_oauth2.this.id
}

resource "authentik_policy_binding" "policy_binding" {
  target = authentik_application.application.uuid
  group  = authentik_group.oidc_group.id
  order  = 0
}

data "authentik_provider_oauth2_config" "config" {
  provider_id = authentik_provider_oauth2.this.id
}
