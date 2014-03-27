///net_send(netInst,id,msgtype,datalist)
var net_vars = argument0;
var net_name, net_key, net_pubport, net_pubtype, net_compatible;
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_type, net_peer_socket;
var net_lanserver;
net_name =              ds_map_find_value(net_vars, "net_name");
net_key =               ds_map_find_value(net_vars, "net_key");
net_pubport =           ds_map_find_value(net_vars, "net_pubport");
net_pubtype =           ds_map_find_value(net_vars, "net_pubtype");
net_compatible =        ds_map_find_value(net_vars, "net_compatible");
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
net_lanserver =         ds_map_find_value(net_vars, "net_lanserver");

var destid, pos, msgtype, datalist;
var destkey, conntype, url, port, socket, time, buffer, str_;
destid = argument1;
msgtype = argument2;
datalist = argument3;
time = string_replace(string_format(current_year, 4, 0)+string_format(current_month, 2, 0)+string_format(current_day, 2, 0)+string_format(current_hour, 2, 0)+string_format(current_minute, 2, 0)+string_format(current_second, 2, 0), " ", "0");

if (destid<0) {
    port = abs(destid);
    buffer = buffer_create(1, buffer_grow, 1);
    buffer_seek(buffer, buffer_seek_start, 0);
    buffer_write(buffer, buffer_string, "[OPENP2PNET]");
    buffer_write(buffer, buffer_string, "msg:"+string(msgtype));
    buffer_write(buffer, buffer_string, "type:"+string(NET_BROADCAST));
    buffer_write(buffer, buffer_string, "srckey:"+net_key);
    buffer_write(buffer, buffer_string, "srcname:"+net_name);
    buffer_write(buffer, buffer_string, "srcport:"+string(net_pubport));
    buffer_write(buffer, buffer_string, "srctype:"+string(net_pubtype));
    buffer_write(buffer, buffer_string, "key:-1");
    buffer_write(buffer, buffer_string, "time:"+time);
    buffer_write(buffer, buffer_string, "typeid:"+string(game_id));
    buffer_write(buffer, buffer_string, "[DATA]");
    for (var i=0; i<ds_list_size(datalist); i++) {
        buffer_write(buffer, buffer_string, string(ds_list_find_value(datalist, i)));
    }
    network_send_broadcast(net_lanserver, port, buffer, buffer_get_size(buffer));
    buffer_delete(buffer);
} else if (destid==0 || ds_list_find_index(net_peer_id, destid)<0) {
    for (pos=0; pos<ds_list_size(net_peer_id); pos++) {
        destkey = ds_list_find_value(net_peer_key, pos);
        conntype = ds_list_find_value(net_peer_nettype, pos);
        url = ds_list_find_value(net_peer_ip, pos);
        port = ds_list_find_value(net_peer_port, pos);
        socket = ds_list_find_value(net_peer_socket, pos);
        switch (conntype) {
            case NET_UDP:
            case NET_TCP:
            case NET_TCPRAW:
                buffer = buffer_create(1, buffer_grow, 1);
                buffer_seek(buffer, buffer_seek_start, 0);
                buffer_write(buffer, buffer_string, "[OPENP2PNET]");
                buffer_write(buffer, buffer_string, "msg:"+string(msgtype));
                buffer_write(buffer, buffer_string, "type:"+string(conntype));
                buffer_write(buffer, buffer_string, "srckey:"+net_key);
                buffer_write(buffer, buffer_string, "srcname:"+net_name);
                buffer_write(buffer, buffer_string, "srcport:"+string(net_pubport));
                buffer_write(buffer, buffer_string, "srctype:"+string(net_pubtype));
                buffer_write(buffer, buffer_string, "key:"+destkey);
                buffer_write(buffer, buffer_string, "time:"+time);
                buffer_write(buffer, buffer_string, "typeid:"+string(game_id));
                buffer_write(buffer, buffer_string, "[DATA]");
                for (var i=0; i<ds_list_size(datalist); i++) {
                    buffer_write(buffer, buffer_string, string(ds_list_find_value(datalist, i)));
                }
                switch (conntype) {
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
                str_ = "[OPENP2PNET]"+chr(10);
                str_ += "msg:"+string(msgtype)+chr(10);
                str_ += "type:"+string(conntype)+chr(10);
                str_ += "srckey:"+net_key+chr(10);
                str_ += "srcname:"+net_name+chr(10);
                str_ += "srcport:"+string(net_pubport)+chr(10);
                str_ += "srctype:"+string(net_pubtype)+chr(10);
                str_ += "key:"+destkey+chr(10);
                str_ += "time:"+time+chr(10);
                str_ += "typeid:"+string(game_id)+chr(10);
                str_ += "[DATA]";
                for (var i=0; i<ds_list_size(datalist); i++) {
                    str_ += chr(10)+string(ds_list_find_value(datalist, i));
                }
                str_ = url+"?"+base64_encode(str_);
                http_get(str_);
                break;
        }
    }
} else {
    pos = ds_list_find_index(net_peer_id, destid);
    destkey = ds_list_find_value(net_peer_key, pos);
    conntype = ds_list_find_value(net_peer_nettype, pos);
    url = ds_list_find_value(net_peer_ip, pos);
    port = ds_list_find_value(net_peer_port, pos);
    socket = ds_list_find_value(net_peer_socket, pos);
    switch (conntype) {
        case NET_UDP:
        case NET_TCP:
        case NET_TCPRAW:
            buffer = buffer_create(1, buffer_grow, 1);
            buffer_seek(buffer, buffer_seek_start, 0);
            buffer_write(buffer, buffer_string, "[OPENP2PNET]");
            buffer_write(buffer, buffer_string, "msg:"+string(msgtype));
            buffer_write(buffer, buffer_string, "type:"+string(conntype));
            buffer_write(buffer, buffer_string, "srckey:"+net_key);
            buffer_write(buffer, buffer_string, "srcname:"+net_name);
            buffer_write(buffer, buffer_string, "srcport:"+string(net_pubport));
            buffer_write(buffer, buffer_string, "srctype:"+string(net_pubtype));
            buffer_write(buffer, buffer_string, "key:"+destkey);
            buffer_write(buffer, buffer_string, "time:"+time);
            buffer_write(buffer, buffer_string, "typeid:"+string(game_id));
            buffer_write(buffer, buffer_string, "[DATA]");
            for (var i=0; i<ds_list_size(datalist); i++) {
                buffer_write(buffer, buffer_string, string(ds_list_find_value(datalist, i)));
            }
            switch (conntype) {
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
            str_ = "[OPENP2PNET]"+chr(10)
            str_ += "msg:"+string(msgtype)+chr(10);
            str_ += "type:"+string(conntype)+chr(10);
            str_ += "srckey:"+net_key+chr(10);
            str_ += "srcname:"+net_name+chr(10);
            str_ += "srcport:"+string(net_pubport)+chr(10);
            str_ += "srctype:"+string(net_pubtype)+chr(10);
            str_ += "key:"+destkey+chr(10);
            str_ += "time:"+time+chr(10);
            str_ += "typeid:"+string(game_id)+chr(10);
            str_ += "[DATA]";
            for (var i=0; i<ds_list_size(datalist); i++) {
                str_ += chr(10)+string(ds_list_find_value(datalist, i));
            }
            str_ = url+"?"+base64_encode(str_);
            http_get(str_);
            break;
    }
}
