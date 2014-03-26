///net_disconnect(netInst,id);
var net_vars = argument0;
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_type, net_peer_socket, net_peer_typeid;
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
net_peer_typeid =       ds_map_find_value(net_vars, "net_peer_typeid");
var _id, pos, type;
_id = argument1;
pos = ds_list_find_index(net_peer_id, _id);
if (pos<0) return -1;
type = ds_list_find_value(net_peer_nettype, pos);

switch (type) {
    case NET_UDP:
        var buffer = ds_list_create();
        net_send(net_vars, _id, MSG_DISCONN, buffer);
        ds_list_destroy(buffer);
    case NET_TCP:
    case NET_TCPRAW:
    case NET_BROADCAST:
        var socket = ds_list_find_value(net_peer_socket, pos);
        network_destroy(socket);
        break;
    case NET_HTTP:
        break;
}

ds_list_delete(net_peer_id, pos);
ds_list_delete(net_peer_key, pos);
ds_list_delete(net_peer_ip, pos);
ds_list_delete(net_peer_port, pos);
ds_list_delete(net_peer_nettype, pos);
ds_list_delete(net_peer_name, pos);
ds_list_delete(net_peer_ping, pos);
ds_list_delete(net_peer_lastping, pos);
ds_list_delete(net_peer_pingrecv, pos);
ds_list_delete(net_peer_type, pos);
ds_list_delete(net_peer_socket, pos);
ds_list_delete(net_peer_typeid, pos);
