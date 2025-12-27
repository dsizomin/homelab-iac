terraform {
  required_version = ">= 1.6"
  required_providers {
    adguard = {
      source  = "gmichels/adguard"
      version = "1.6.2"
    }
  }
}

resource "adguard_config" "config" {
  dns = {
    upstream_dns = [
      "sdns://AQMAAAAAAAAADTkuOS45LjEwOjg0NDMgZ8hHuMh1jNEgJFVDvnVnRt803x2EwAuMRwNo34Idhj4ZMi5kbnNjcnlwdC1jZXJ0LnF1YWQ5Lm5ldA",
      "https://dns11.quad9.net/dns-query",
      "tls://dns11.quad9.net"
    ],
    bootstrap_dns = [
      "9.9.9.9",
      "149.112.112.11",
      "2620:fe::11",
      "2620:fe::fe:11"
    ],

    use_private_ptr_resolvers = true,
    local_ptr_upstreams = [
      "192.168.1.1:53"
    ]
  }
}

resource "adguard_list_filter" "adguard_dns_filter" {
  name = "AdGuard DNS filter"
  url  = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
}

resource "adguard_list_filter" "adguard_default_blocklist" {
  name = "AdAway Default Blocklist"
  url  = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"
}

resource "adguard_list_filter" "hagezi_pro_plusplus" {
  name = "Hagezi Pro++"
  url  = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_41.txt"
}

resource "adguard_rewrite" "rewrite" {
  domain = "*.${var.dns_config.zone}"
  answer = var.reverse_proxy_ip
}

resource "adguard_user_rules" "rules" {
  rules = [
    "@@||stats.grafana.org^$important"
  ]
}
