locals {
  dns_server_name = var.dns_server_name != "" ? var.dns_server_name : "ns.${var.domain}."
  email = var.email != "" ? var.email : "no-op.${var.domain}."
}

locals {
  zonefile_md5 = md5(
      templatefile(
        "${path.module}/zonefile.tpl",
        {
          domain = var.domain
          serial_number = "temp"
          cache_ttl = var.cache_ttl
          ns_records = var.ns_records
          a_records = var.a_records
          cname_records = var.cname_records
          mx_records = var.mx_records
          txt_records = var.txt_records
          dns_server_name = local.dns_server_name
          email = local.email
          dns_server_ips = var.dns_server_ips
        }
      )
  )
}

resource "time_static" "zonefile_update" {
  triggers = {
    zonefile_md5 = local.zonefile_md5
  }
}

resource "etcd_key" "zonefile" {
  key = "${var.key_prefix}${var.domain}"
  value = templatefile(
    "${path.module}/zonefile.tpl",
    {
      domain = var.domain
      serial_number = time_static.zonefile_update.unix
      cache_ttl = var.cache_ttl
      ns_records = var.ns_records
      a_records = var.a_records
      cname_records = var.cname_records
      mx_records = var.mx_records
      txt_records = var.txt_records
      dns_server_name = local.dns_server_name
      email = local.email
      dns_server_ips = var.dns_server_ips
    }
  )
  clear_on_deletion = var.clear_on_deletion
}