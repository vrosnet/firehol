#!/bin/sh


if [ ! -f ../firehol.sh -o ! -f services.html ]
then
	echo "Please step into the 'doc' directory of firehol"
	exit 1
fi

server_all_ports="all"
client_all_ports="all"
service_all_type="complex"
service_all_notes="
Matches all traffic (all protocols, ports, etc) while ensuring that required kernel modules are loaded.
<br>This service may indirectly setup a set of other services, if they are required by the kernel modules to be loaded.
Currently it activates also <a href=\"#ftp\">ftp</a>, <a href=\"#irc\">irc</a> and <a href=\"#icmp\">icmp</a>.
"


server_any_ports="all"
client_any_ports="all"
service_any_type="complex"
service_any_notes="
Matches all traffic (all protocols, ports, etc), but does not care about kernel modules and does not activate any other service indirectly.
In combination with the <a href=\"commands.html#parameters\">Optional Rule Parameters</a> this service can match unusual traffic (e.g. GRE - protocol 47).
"
service_any_example="server any <u>myname</u> accept proto 47"


server_custom_ports="defined&nbsp;in&nbsp;the&nbsp;command"
client_custom_ports="defined&nbsp;in&nbsp;the&nbsp;command"
service_custom_type="complex"
service_custom_notes="
This service is used by FireHOL to allow you define services it currently does not support.<br>
To find more about this service please check the <a href=\"adding.html\">Adding Services</a> section.
"
service_custom_example="server custom <u>myimap</u> <u>tcp/143</u> <u>default</u> accept"


server_dns_ports="udp/domain tcp/domain"
client_dns_ports="all"
service_dns_type="complex"
service_dns_notes="
The DNS service has been made a complex service (although is was not required) to achieve stateless operation on UDP
and stateful on TCP. This differentiation has been made because in some production environments with heavily loaded
DNS servers
we observed many drops on UDP port 53. The DNS server was not responding in time
and the iptables connection tracker drops all new connections that have not been assured in 19 (if I remember correct) seconds.
<br>
Although the mentioned drops were not a real problem, since the client had already timed out, we prefered to
operate DNS without state.
"


server_ftp_ports="many"
client_ftp_ports="many"
service_ftp_type="complex"
service_ftp_notes="
The FTP service matches both active and passive FTP connections by utilizing the FTP connection tracker kernel module.
"


service_icmp_type="complex"


server_multicast_ports="N/A"
client_multicast_ports="N/A"
service_multicast_type="complex"
service_multicast_notes="
The multicast service matches all packets send to 224.0.0.0/8
"


service_netbios_ns_notes="
See also the <a href=\"#samba\">samba</a> service.
"
service_netbios_dgm_notes="
See also the <a href=\"#samba\">samba</a> service.
"
service_netbios_ssn_notes="
See also the <a href=\"#samba\">samba</a> service.
"


server_nfs_ports="many"
client_nfs_ports="500:65535"
service_nfs_type="complex"
service_nfs_notes="
The NFS service queries the RPC service on the NFS server host to find out the ports <b>nfsd</b> and <b>mountd</b> are listening.
Then, according to these ports it sets up rules on all the supported protocols (as reported by RPC) in order the
clients to be able to reach the server.
<p>
For this reason, the NFS service requires that:
<ul>
	<li>the firewall is restarted if the NFS server is restarted</li>
	<li>the NFS server must be specified on all nfs statements (only if it is not the localhost)</li>
</ul>
Since NFS queries the remote RPC server, it is required to also be allowed to do so, by allowing the
<a href=\"#portmap\">portmap</a> service too. Take care, that this is allowed by the <b>running firewall</b>
when FireHOL tries to query the RPC server. So you might have to setup NFS in two steps: First add the portmap
service and activate the firewall, then add the NFS service and restart the firewall.
"
service_nfs_example="client nfs accept <u>dst</u> <u>1.2.3.4</u>"


server_pptp_ports="tcp/1723"
client_pptp_ports="default"
service_pptp_type="complex"
service_pptp_notes="
Additionally to the above the PPTP service allows stateful GRE traffic (protocol 47) to flow between the PPTP server and the client.
"


server_samba_ports="many"
client_samba_ports="default"
service_samba_type="complex"
service_samba_notes="
The samba service automatically sets all the rules for <b>netbios-ns</b>, <b>netbios-dgm</b> and <b>netbios-ssn</b>.
"


service_heartbeat_notes="
HeartBeat is the Linux clustering solution available <a href="http://www.linux-ha.org/">http://www.linux-ha.org/</a>.
This FireHOL service has been designed such a way that it will allow multiple heartbeat clusters on the same LAN.
"


# header
cat <<"EOF"
<HTML>
<HEAD>
<link rel="stylesheet" type="text/css" href="css.css">
<TITLE>FireHOL, supported services</TITLE>
</HEAD>

<BODY bgcolor="#FFFFFF">

<center>
<table border=0 cellspacing=5 cellpadding=10 width="80%">
<tr bgcolor="#EEEEEE"><th>Service</th><th>Type</th><th>Description</th></tr>
EOF


scount=0
print_service() {
	scount=$[scount + 1]
	
	if [ $scount -gt 1 ]
	then
		color=' bgcolor="#F0F0F0"'
		scount=0
	else
		color=""
	fi
	
	service="${1}";	shift
	type="${1}";	shift
	sports="${1}";	shift
	dports="${1}";	shift
	example="${1}";	shift
	notes="${*}"
	
	
cat <<EOF
<tr ${color}>
	<td align="center"><a name="${service}"><b>${service}</a></td>
	<td align="center">${type}</td>
	<td>
		<table cellspacing=0 cellpadding=2 border=0>
		<tr>
EOF
	echo "<td align=right valign=top nowrap><small><font color="gray">Server Ports</td><td>"
	c=0
	for x in ${sports}
	do
		if [ $c -ne 0 ]
		then
			echo ", "
		fi
		
		echo "<b>${x}</b>"
		c=$[c + 1]
	done
	
	echo "</td></tr><tr><td align=right valign=top nowrap><small><font color="gray">Client Ports</td><td>"
	c=0
	for x in ${dports}
	do
		if [ $c -ne 0 ]
		then
			echo ", "
		fi
		
		echo "<b>${x}</b>"
		c=$[c + 1]
	done
	
	echo "</td>"
	
cat <<EOF
	</tr>
	<tr><td align=right valign=top nowrap><small><font color="gray">Notes</td><td>${notes}<br>&nbsp;</td></tr>
	<tr><td align=right valign=top nowrap><small><font color="gray">Example</td><td><b>${example}</b></td></tr>
	</table>
	</td></tr>
EOF
}

smart_print_service() {
	local server="${1}"
	
	local server_varname="server_${server}_ports"
	local server_ports="`eval echo \\\$${server_varname}`"
	
	local client_varname="client_${server}_ports"
	local client_ports="`eval echo \\\$${client_varname}`"
	
	local notes_varname="service_${server}_notes"
	local notes="`eval echo \\\$${notes_varname}`"
	
	local type_varname="service_${server}_type"
	local type="`eval echo \\\$${type_varname}`"
	
	if [ -z "${type}" ]
	then
		local type="simple"
	fi
	
	local example_varname="service_${server}_example"
	local example="`eval echo \\\$${example_varname}`"
	
	if [ -z "${example}" ]
	then
		local example="server ${server} accept"
	fi
	
	print_service "${server}" "${type}" "${server_ports}" "${client_ports}" "${example}" "${notes}"
}



tmp="/tmp/services.$$"

# The simple services
cat "../firehol.sh"			|\
	grep -e "^server_.*_ports=" >"${tmp}"

cat "../firehol.sh"			|\
	grep -e "^client_.*_ports=" >>"${tmp}"

cat "../firehol.sh"			|\
	grep -e "^service_.*_notes=" >>"${tmp}"

. "${tmp}"


(
	cat "../firehol.sh"			|\
		grep -e "^server_.*_ports="	|\
		cut -d '=' -f 1			|\
		sed "s/^server_//"		|\
		sed "s/_ports\$//"
		
	cat "../firehol.sh"			|\
		grep -e "^rules_.*()"		|\
		cut -d '(' -f 1			|\
		sed "s/^rules_//"
) |\
	sort | uniq |\
	(
		while read
		do
			smart_print_service $REPLY
		done
	)


cat <<"EOF"
</table>
</center>
<p>
<hr noshade size=1>
<table border=0 width="100%">
<tr><td align=center valign=middle>
	<A href="http://sourceforge.net"><IMG src="http://sourceforge.net/sflogo.php?group_id=58425&amp;type=5" width="210" height="62" border="0" alt="SourceForge Logo"></A>
</td><td align=center valign=middle>
	<small>$Id: create_services.sh,v 1.2 2002/12/11 09:22:53 ktsaou Exp $</small>
	<p>
	<b>FireHOL</b>, a firewall for humans...<br>
	&copy; Copyright 2002
	Costa Tsaousis <a href="mailto: costa@tsaousis.gr">&lt;costa@tsaousis.gr&gt</a>
</body>
</html>
EOF
