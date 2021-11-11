$ORIGIN ${domain}.
$TTL ${cache_ttl}
@	IN	SOA ${dns_server_name} ${email} (
				${serial_number} ; serial
				7200             ; refresh (2 hours), only affects secondary dns servers
				3600             ; retry (1 hour), only affects secondary dns servers
				604800           ; expire (1 week), only affects secondary dns servers
				${cache_ttl}     ;
				)

%{ for record in a_records ~}
%{ if record.prefix != "" ~}
${record.prefix} IN A ${record.ip}
%{ else ~}
@ IN A ${record.ip}
%{ endif ~}
%{ endfor ~}

%{ for ip in dns_server_ips ~}
${dns_server_name} IN A ${ip}
%{ endfor ~}