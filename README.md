# About

This Terraform module generates a zonefile from the input and stores it in etcd.

The zonefile serial number is internally managed on detected file changes and strictly increasing. 

# Limitations

## DNS Servers Compatibility

The generated zonefiles have so far been used with the **auto** plugin of **CoreDNS** and are thus validated for that technology.

It should theoretically work with other kinds of dns servers, but it has not be empirically verified.

## Supported Refresh Rates

The epoch, in seconds, is used to update the value of the zonefile serial number.

This will be good enough as long as your zonefile is not updated more than once per second. Should you need to update at a greater frequency than that, terraform provisioned dns zonefiles are probably not the right solution for your problem anyhow.

# Usage

## Input

- **domain**: Domain that the zonefile is for. A dot at the end is not required.
- **ns_records**: List of objects, each having a **prefix** (subdomain) and **nameserver** key.
- **a_records**: List of objects, each having a **prefix** (subdomain) and **ip** key. If the **prefix** has the value of the empty string (**""**), the value of **@** is passed to the given record, which will resolve to the domain with no subdomain prefix.
- **cname_records**: List of objects, each having a **prefix** (subdomain) and **fqdn** (domain of target host, with a dot at the end). If the **fqdn** has the value of the empty string (**""**), the value of **@** is passed to the given record, which will resolve to the domain with no subdomain prefix.
- **mx_records**: List of objects, each having a **prefix** (subdomain), **priority** (integer giving email server priority) and **address** (domain of email server). If the **prefix** has the value of the empty string (**""**), the value of **@** is passed to the given record, which will resolve to the domain with no subdomain prefix.
- **txt_records**: List of objects, each having a **prefix** (subdomain), and **text** (value of the text field). If the **prefix** has the value of the empty string (**""**), the value of **@** is passed to the given record, which will resolve to the domain with no subdomain prefix.
- **key_prefix**: Etcd key prefix that will prefix the domain to form the etcd key where the zonefile will be stored.
- **clear_on_deletion**: Whether to delete the generated zonefile in etcd if the module is deleted. Defaults to true, but can be set to false to prevent zonefile deletion during migrations.
- **cache_ttl**: How long (in seconds) should resolvers cache the values retrieved from the zonefile. Defaults to 5 seconds.
- **email**: Email address to put in **SOA** record. This needs to be a fully qualified domain so the **@** should be replaced by a dot and a dot needs to be appeneded at the end. Defaults to **no-op.domain.** if undefined, where **domain** is the domain you passed as an argument.
- **dns_server_name**: Fully qualified domain name of the nameserver (with a dot at the end). Defaults to **ns.domain.** if not defined, where **domain** is the domain you passed as an argument. This is used for the SOA record. For standalone internal DNS servers, it can be ignored and left at the default.
- **dns_server_ips**: If defined, **A** records will be generated mapping the dns server name to those ips.

## Output

The module returns the following output variables:

- key: Generated key in etcd
- value: Content of the generated key (ie, the zonefile)