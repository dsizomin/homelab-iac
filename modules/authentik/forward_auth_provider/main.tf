terraform {
  required_version = ">= 1.6"
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2025.10.0"
    }
  }
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

resource "authentik_provider_proxy" "this" {
  name               = var.name
  external_host      = var.external_host
  skip_path_regex    = var.skip_path_regex
  invalidation_flow  = data.authentik_flow.default_invalidation_flow.id
  authorization_flow = data.authentik_flow.default_authorization_flow.id
  mode               = "forward_single"
}

data "authentik_outpost" "embedded" {
  name = "authentik Embedded Outpost"
}

resource "authentik_outpost_provider_attachment" "attachment_embedded" {
  outpost           = data.authentik_outpost.embedded.id
  protocol_provider = authentik_provider_proxy.this.id
}

resource "authentik_application" "application" {
  name              = title(var.name)
  slug              = var.name
  protocol_provider = authentik_provider_proxy.this.id
}

resource "authentik_policy_binding" "policy_binding" {
  target = authentik_application.application.uuid
  group  = authentik_group.oidc_group.id
  order  = 0
}

