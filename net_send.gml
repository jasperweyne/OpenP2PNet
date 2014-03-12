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
var destkey, conntype, url, port, socket, time, buffer, str_;
destid = argument0;
msgtype = argument1;
datalist = argument2;
time = string_replace(string_format(current_year, 4, 0)+string_format(current_month, 2, 0)+string_format(current_day, 2, 0)+string_format(current_hour, 2, 0)+string_format(current_minute, 2, 0)+string_format(current_second, 2, 0), " ", "0");

if (destid<0) {
    port = abs(destid);
    buffer = buffer_create(1, buffer_grow, 1);
    buffer_seek(buffer, buffer_seek_start, 0);
    buffer_write(buffer, buffer_string, "[OPENP2PNET]");
    buffer_write(buffer, buffer_string, string(msgtype));
    buffer_write(buffer, buffer_string, string(conntype));
    buffer_write(buffer, buffer_string, net_key);
    buffer_write(buffer, buffer_string, net_name);
    buffer_write(buffer, buffer_string, destkey);
    buffer_write(buffer, buffer_string, time);
    buffer_write(buffer, buffer_string, "[DATA]");
    for (var i=0; i<ds_list_size(datalist); i++) {
        buffer_write(buffer, buffer_string, string(ds_list_find_value(datalist, i)));
    }
    network_send_broadcast(socket, port, buffer, buffer_get_size(buffer));
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
                buffer_write(buffer, buffer_string, "key:"+destkey);
                buffer_write(buffer, buffer_string, "time"+time);
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
                str_ = url+"?protocol=OpenP2PNet";
                str_ += "&msg="+string(msgtype);
                str_ += "&type="+string(conntype);
                str_ += "&srckey="+net_key;
                str_ += "&srcname="+net_name;
                str_ += "&key="+destkey;
                str_ += "&time="+time;
                for (var i=0; i<ds_list_size(datalist); i++) {
                    str_ += "&OP2PNdata_"+string(i)+"="+string(ds_list_find_value(datalist, i));
                }
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
            buffer_write(buffer, buffer_string, "key:"+destkey);
            buffer_write(buffer, buffer_string, "time:"+time);
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
            str_ = url+"?protocol=OpenP2PNet";
            str_ += "&msg="+string(msgtype);
            str_ += "&type="+string(conntype);
            str_ += "&srckey="+net_key;
            str_ += "&srcname="+net_name;
            str_ += "&key="+destkey;
            str_ += "&time="+time;
            for (var i=0; i<ds_list_size(datalist); i++) {
                str_ += "&OP2PNdata_"+string(i)+"="+string(ds_list_find_value(datalist, i));
            }
            http_get(str_);
            break;
    }
}
