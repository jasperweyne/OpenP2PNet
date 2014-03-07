globalvar net_vars;
var net_interval;
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_type, net_peer_socket;
var net_cmdlist;
var net_devicemaster, net_devicemasterid, net_timer;
//Download vars
net_interval =          ds_map_find_value(net_vars, "net_interval");
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
net_cmdlist =           ds_map_find_value(net_vars, "net_cmdlist");
net_devicemaster =      ds_map_find_value(net_vars, "net_devicemaster");
net_devicemasterid =    ds_map_find_value(net_vars, "net_devicemasterid");
net_timer =             ds_map_find_value(net_vars, "net_timer");
var outputlist = ds_list_create();

if (net_timer==0) {
    ds_list_clear(outputlist);
    net_push(NET_BROADCAST, -1, 6510, "-1", MSG_INFO, outputlist);
    if (net_devicemaster==false) {
        ds_list_clear(outputlist);
        net_send(net_devicemasterid, MSG_PEERREQUEST, outputlist);
    }
    net_timer = net_interval;
}
net_timer--;
for (var i=0; i<ds_list_size(net_peer_lastping); i++) {
    if (get_timer()-ds_list_find_value(net_peer_lastping, i)>net_interval/room_speed*1000000){// || ds_list_find_value(net_peer_ping, i)==0) {
        ds_list_clear(outputlist);
        ds_list_add(outputlist, get_timer());
        var _id = ds_list_find_value(net_peer_id, i);
        net_send(_id, MSG_PING, outputlist);
        ds_list_replace(net_peer_lastping, i, get_timer());
    }
}

if (ds_list_size(net_cmdlist)>0) {
    repeat (ds_list_size(net_cmdlist)) {
        var execlist, timer;
        execlist = ds_list_find_value(net_cmdlist, 0);
        timer = ds_list_find_value(execlist, 1);
        if (timer>0) {
            ds_list_replace(execlist, 1, timer-1);
            continue;
        }
        switch (ds_list_find_value(execlist, 0)) {
            case CMD_PING:
                var _id = ds_list_find_value(net_cmdlist, 1);
                if (ds_list_find_index(net_peer_id, _id)<0) break;
                ds_list_clear(outputlist);
                ds_list_add(outputlist, get_timer());
                net_send(_id, MSG_PING, outputlist);
                break;
        }
        ds_list_destroy(execlist);
        ds_list_delete(net_cmdlist, 0);
    }
}

ds_list_destroy(outputlist);

//Upload vars
ds_map_replace(net_vars, "net_timer", net_timer);
