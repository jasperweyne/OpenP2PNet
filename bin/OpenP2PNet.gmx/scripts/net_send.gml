///net_send(id,msgtype,datalist)
globalvar net_vars;
var net_key, net_name;
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_type, net_peer_socket;
net_key =               ds_map_find_value(net_vars, "net_key");
net_name =              ds_map_find_value(net_vars, "net_name");
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

var destid, pos, msgtype, datalist;
var destkey, conntype, url, port, socket, buffer, str_;
destid = argument0;
pos = ds_list_find_index(net_peer_id, destid);
if (pos<0) return -1;

destkey = ds_list_find_value(net_peer_key, pos);
conntype = ds_list_find_value(net_peer_nettype, pos);
url = ds_list_find_value(net_peer_ip, pos);
port = ds_list_find_value(net_peer_port, pos);
socket = ds_list_find_value(net_peer_socket, pos);
msgtype = argument1;
datalist = argument2;

switch (conntype) {
    case NET_BROADCAST:
    case NET_UDP:
    case NET_TCP:
    case NET_TCPRAW:
        buffer = buffer_create(1, buffer_grow, 1);
        buffer_seek(buffer, buffer_seek_start, 0);
        buffer_write(buffer, buffer_string, "[OPENP2PNET][v0.1.0.0]");
        buffer_write(buffer, buffer_string, string(msgtype));
        buffer_write(buffer, buffer_string, string(conntype));
        buffer_write(buffer, buffer_string, net_key);
        buffer_write(buffer, buffer_string, net_name);
        buffer_write(buffer, buffer_string, "-1"); //Signature
        //Hash from here
        buffer_write(buffer, buffer_string, destkey);
        buffer_write(buffer, buffer_string, get_time_string());
        for (var i=0; i<ds_list_size(datalist); i++) {
            buffer_write(buffer, buffer_string, string(ds_list_find_value(datalist, i)));
        }
        switch (conntype) {
            case NET_BROADCAST:
                network_send_broadcast(socket, port, buffer, buffer_get_size(buffer));
                break;
            case NET_UDP:
                network_send_udp(socket, url, port, buffer, buffer_get_size(buffer));
                break;
            case NET_TCP:
            case NET_TCPRAW:
                network_send_packet(socket, buffer, buffer_get_size(buffer));
                break;
        }
        buffer_delete(buffer);
        break;
    case NET_HTTP:
        str_ = url+"?OP2PNdata_0=[OPENP2PNET][v0.1.0.0]";
        str_ += "&OP2PNdata_1="+string(msgtype);
        str_ += "&OP2PNdata_2="+string(conntype);
        str_ += "&OP2PNdata_3="+net_key;
        str_ += "&OP2PNdata_4="+net_name;
        str_ += "&OP2PNdata_5="+"-1";
        //Hash
        str_ += "&OP2PNdata_6="+destkey;
        str_ += "&OP2PNdata_7="+get_time_string();
        for (var i=0; i<ds_list_size(datalist); i++) {
            str_ += "&OP2PNdata_"+string(i+8)+"="+string(ds_list_find_value(datalist, i));
        }
        http_get(str_);
        break;
}
