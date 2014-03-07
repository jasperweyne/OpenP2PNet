///net_push(conntype,url,port,key,msgtype,datalist)
globalvar net_vars;
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_type, net_peer_socket;
var net_idcounter;
net_peer_id =           ds_map_find_value(net_vars, "net_peer_id");
net_peer_key =          ds_map_find_value(net_vars, "net_peer_key");
net_peer_ip =           ds_map_find_value(net_vars, "net_peer_ip");
net_peer_port =         ds_map_find_value(net_vars, "net_peer_port");
net_peer_nettype =      ds_map_find_value(net_vars, "net_peer_nettype");
net_peer_name =         ds_map_find_value(net_vars, "net_peer_name");
net_peer_ping =         ds_map_find_value(net_vars, "net_peer_ping");
net_peer_lastping =     ds_map_find_value(net_vars, "net_peer_lastping");
net_peer_pingrecv =     ds_map_find_value(net_vars, "net_peer_pingrecv");
net_peer_type =         ds_map_find_value(net_vars, "net_peer_type");
net_peer_socket =       ds_map_find_value(net_vars, "net_peer_socket");
net_idcounter =         ds_map_find_value(net_vars, "net_idcounter");
net_idcounter++;
ds_map_replace(net_vars, "net_idcounter", net_idcounter);
var socket, conntype, url, port, key;
socket = -1;
conntype = argument0;
url = argument1;
port = argument2;
key = argument3;
while (socket<0) {
    switch (argument0) {
        case NET_BROADCAST:
        case NET_UDP:
            socket = network_create_socket(network_socket_udp);
            break;
        case NET_TCP:
        case NET_TCPRAW:
            socket = network_create_socket(network_socket_tcp);
            break;
        case NET_HTTP:
            socket = 0;
            break;
    }
}
if (argument0==NET_TCP || argument0==NET_TCPRAW) {
    var conn, i;
    conn = -1;
    i = 0;
    while (conn<0) {
        if (argument0==NET_TCP) {
            if (i>=5) return -1;
            conn = network_connect(socket, url, port);
        } else {
            conn = network_connect_raw(socket, url, port);
        }
        i++;
    }
}
ds_list_add(net_peer_id, net_idcounter);
ds_list_add(net_peer_key, key);
ds_list_add(net_peer_ip, url);
ds_list_add(net_peer_port, port);
ds_list_add(net_peer_nettype, conntype);
ds_list_add(net_peer_name, "?");
ds_list_add(net_peer_ping, 0);
ds_list_add(net_peer_lastping, 0);
ds_list_add(net_peer_pingrecv, 0);
ds_list_add(net_peer_type, NETTYPE_PEER);
ds_list_add(net_peer_socket, socket);

net_send(net_idcounter, argument4, argument5);

net_disconnect(net_idcounter);
