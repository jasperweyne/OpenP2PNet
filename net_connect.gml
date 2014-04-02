///net_connect(netInst,conntype,key,[url],[port])
var net_vars = argument[0];
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_lan, net_peer_socket, net_peer_typeid;
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
net_peer_lan =          ds_map_find_value(net_vars, "net_peer_lan");
net_peer_socket =       ds_map_find_value(net_vars, "net_peer_socket");
net_peer_typeid =       ds_map_find_value(net_vars, "net_peer_typeid");
net_idcounter =         ds_map_find_value(net_vars, "net_idcounter");
net_idcounter++;
ds_map_replace(net_vars, "net_idcounter", net_idcounter);

var socket, conntype, key, url, port;
socket = -1;
conntype = argument[1];
key = argument[2];
if (argument_count>=5) {
    url = argument[3];
    port = argument[4];
} else {
    url = "?";
    port = 0;
}
while (socket<0) {
    switch (conntype) {
        case "NET_BROADCAST":
        case "NET_UDP":
            socket = network_create_socket(network_socket_udp);
            break;
        case "NET_TCP":
        case "NET_TCPRAW":
            socket = network_create_socket(network_socket_tcp);
            break;
        case "NET_HTTP":
            socket = 0;
            break;
    }
}

if (argument_count>=5) {
    if (conntype=="NET_TCP" || conntype=="NET_TCPRAW") {
        var conn, i;
        conn = -1;
        i = 0;
        while (conn<-1) {
            if (conntype=="NET_TCP") {
                if (i>=5) return -1;
                conn = network_connect(socket, url, port);
            } else {
                conn = network_connect_raw(socket, url, port);
            }
            i++;
        }
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
ds_list_add(net_peer_lan, false);
ds_list_add(net_peer_socket, socket);
ds_list_add(net_peer_typeid, "?");

if (argument_count>=5 || conntype=="NET_UDP") {
    var buffer = ds_list_create();
    net_send(net_vars, net_idcounter, "MSG_CONN", buffer);
    ds_list_destroy(buffer);
}

return net_idcounter;
