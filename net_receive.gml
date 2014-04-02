///net_receive(netInst,eventtype,ds_list,ip,port,socket)
/******************
** RETURN VALUES **
*******************
**   1: Message correctly handled
**   0: Error in message or unknown protocol
**  <0: Unknown message ID, abs(val) is ds_map containing headers (make sure to remove after use!)
*/
var net_vars = argument0;
var net_key;
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_lan, net_peer_socket, net_peer_typeid;
var net_msglist, net_idcounter;
var net_lanserver, net_pubserver;
//Download vars
net_key =               ds_map_find_value(net_vars, "net_key");
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
net_msglist =           ds_map_find_value(net_vars, "net_msglist");
net_idcounter =         ds_map_find_value(net_vars, "net_idcounter");
net_lanserver =         ds_map_find_value(net_vars, "net_lanserver");
net_pubserver =         ds_map_find_value(net_vars, "net_pubserver");
var recvevent, recvlist, recvheaders, recvip, recvport, recvsocket, recvmsg, recvtype, recvkey, recvname, recvpubport, recvpubtype, recvtypeid, recvtokey, recvtime, recvhash, datalist, datastart;

recvevent = argument1;
recvlist = argument2;
recvip = argument3;
recvport = argument4;
recvsocket = argument5;

//TCP Connect/Disconnect
if (recvevent!=network_type_data) {
    if (recvevent==network_type_connect) {
        //Connect
        net_idcounter++;
        ds_map_replace(net_vars, "net_idcounter", net_idcounter);
        ds_list_add(net_peer_id, net_idcounter);
        ds_list_add(net_peer_key, "?");
        ds_list_add(net_peer_ip, recvip);
        ds_list_add(net_peer_port, recvport);
        ds_list_add(net_peer_nettype, "NET_TCP"); //Since you can't run a raw server, and all other protocols are connectionless, it must be built-in TCP
        ds_list_add(net_peer_name, "?");
        ds_list_add(net_peer_ping, 0);
        ds_list_add(net_peer_lastping, 0);
        ds_list_add(net_peer_pingrecv, 0);
        ds_list_add(net_peer_lan, false);
        ds_list_add(net_peer_socket, recvsocket);
        ds_list_add(net_peer_typeid, "?");
    } else {
        //Disconnect
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        ds_list_delete(net_peer_id, pos);
        ds_list_delete(net_peer_key, pos);
        ds_list_delete(net_peer_ip, pos);
        ds_list_delete(net_peer_port, pos);
        ds_list_delete(net_peer_nettype, pos);
        ds_list_delete(net_peer_name, pos);
        ds_list_delete(net_peer_ping, pos);
        ds_list_delete(net_peer_lastping, pos);
        ds_list_delete(net_peer_pingrecv, pos);
        ds_list_delete(net_peer_lan, pos);
        ds_list_delete(net_peer_socket, pos);
        ds_list_delete(net_peer_typeid, pos);
    }
    return 1;
}

//Test whether package empty
if (ds_list_size(recvlist)==0) return 1;

//Add headers to map
if (ds_list_find_value(recvlist, 0)!="[OPENP2PNET]") return 0;
var dsMap = ds_map_create();
for (var i=1; ds_list_find_value(recvlist, i)!="[DATA]"; i++) {
    var mapstr, key, val;
    mapstr = ds_list_find_value(recvlist, i);
    key = string_copy(mapstr, 1, string_pos(":", mapstr)-1);
    val = string_delete(mapstr, 1, string_pos(":", mapstr));
    ds_map_add(dsMap, key, val);
}
datastart = i+1;

//Check dependency vars (type, key, tokey, time)
if (ds_map_exists(dsMap, "type")==false  || ds_map_exists(dsMap, "srckey")==false  || ds_map_exists(dsMap, "key")==false  || ds_map_exists(dsMap, "time")==false) {
    ds_map_destroy(dsMap);
    return 0;
} else {
    recvtype = ds_map_find_value(dsMap, "type");
    recvkey = ds_map_find_value(dsMap, "srckey");
    recvtokey = ds_map_find_value(dsMap, "key");
    recvtime = ds_map_find_value(dsMap, "time");
    if (ds_map_exists(dsMap, "msg")==true) recvmsg = ds_map_find_value(dsMap, "msg"); else recvmsg = "default";
    if (ds_map_exists(dsMap, "srcname")==true) recvname = ds_map_find_value(dsMap, "srcname"); else recvname = "?";
    if (ds_map_exists(dsMap, "srcport")==true) recvpubport = real(ds_map_find_value(dsMap, "srcname")); else recvpubport = 0;
    if (ds_map_exists(dsMap, "srctype")==true) recvpubtype = ds_map_find_value(dsMap, "srctype"); else recvpubtype = "default";
    if (ds_map_exists(dsMap, "typeid")==true) recvtypeid = ds_map_find_value(dsMap, "typeid"); else recvtypeid = "?";
    ds_map_add(dsMap, "ip", recvip);
    ds_map_add(dsMap, "port", recvport);
    ds_map_add(dsMap, "datastart", datastart);
    recvheaders = ds_map_write(dsMap);
    ds_map_destroy(dsMap);
}

//Add new peers
switch (recvtype) {
    case "NET_TCP":
    case "NET_TCPRAW":
        //Handled above
        break;
    case "NET_HTTP":
        //Impossible to init from server, late messages will be denied
        if (ds_list_find_index(net_peer_key, recvkey)<0) return 1;
        break;
    case "NET_BROADCAST":
        if (ds_list_find_index(net_peer_key, recvkey)<0 && recvkey!=net_key) {
            recvsocket = -1;
            while (recvsocket<0) recvsocket = network_create_socket(network_socket_udp);
            net_idcounter++;
            ds_map_replace(net_vars, "net_idcounter", net_idcounter);
            ds_list_add(net_peer_id, net_idcounter);
            ds_list_add(net_peer_key, recvkey);
            ds_list_add(net_peer_ip, recvip);
            ds_list_add(net_peer_port, recvport);
            ds_list_add(net_peer_nettype, "NET_UDP");
            ds_list_add(net_peer_name, recvname);
            ds_list_add(net_peer_ping, 0);
            ds_list_add(net_peer_lastping, 0);
            ds_list_add(net_peer_pingrecv, 0);
            ds_list_add(net_peer_lan, true);
            ds_list_add(net_peer_socket, recvsocket);
            ds_list_add(net_peer_typeid, recvtypeid);
        }
        break;
    case "NET_UDP":
        if (recvsocket==net_lanserver || recvsocket==net_pubserver) {
            recvsocket = -1;
            while (recvsocket<0) recvsocket = network_create_socket(network_socket_udp);
            net_idcounter++;
            ds_map_replace(net_vars, "net_idcounter", net_idcounter);
            ds_list_add(net_peer_id, net_idcounter);
            ds_list_add(net_peer_key, recvkey);
            ds_list_add(net_peer_ip, recvip);
            ds_list_add(net_peer_port, recvport);
            ds_list_add(net_peer_nettype, "NET_UDP");
            ds_list_add(net_peer_name, recvname);
            ds_list_add(net_peer_ping, 0);
            ds_list_add(net_peer_lastping, 0);
            ds_list_add(net_peer_pingrecv, 0);
            ds_list_add(net_peer_lan, false);
            ds_list_add(net_peer_socket, recvsocket);
            ds_list_add(net_peer_typeid, recvtypeid);
        }
        break;
}

//Update info
if (recvkey!=net_key) {
    var pos = ds_list_find_index(net_peer_key, recvkey);
    if (ds_list_find_value(net_peer_port, pos)==0) ds_list_replace(net_peer_port, pos, recvport);
    if (ds_list_find_value(net_peer_name, pos)=="?") ds_list_replace(net_peer_name, pos, recvname);
    if (ds_list_find_value(net_peer_typeid, pos)=="?") ds_list_replace(net_peer_typeid, pos, recvtypeid);
}

//Modify vars when forwared message
while (recvmsg=="MSG_FORWARD") {
    recvip = ds_list_find_value(recvlist, datastart);
    recvport = real(ds_list_find_value(recvlist, datastart+1));
    
    //Add headers to map
    if (ds_list_find_value(recvlist, datastart+2)!="[OPENP2PNET]") return 0;
    var dsMap = ds_map_create();
    for (var i=datastart+3; ds_list_find_value(recvlist, i)!="[DATA]"; i++) {
        var mapstr, key, val;
        mapstr = ds_list_find_value(recvlist, i);
        key = string_copy(mapstr, 1, string_pos(":", mapstr)-1);
        val = string_delete(mapstr, 1, string_pos(":", mapstr));
        ds_map_add(dsMap, key, val);
    }
    datastart = i+1;
    
    //Check dependency vars (type, key, tokey, time)
    if (ds_map_exists(dsMap, "type")==false  || ds_map_exists(dsMap, "srckey")==false  || ds_map_exists(dsMap, "key")==false  || ds_map_exists(dsMap, "time")==false) {
        ds_map_destroy(dsMap);
        return 0;
    } else {
        recvtype = ds_map_find_value(dsMap, "type");
        recvkey = ds_map_find_value(dsMap, "srckey");
        recvtokey = ds_map_find_value(dsMap, "key");
        recvtime = ds_map_find_value(dsMap, "time");
        if (ds_map_exists(dsMap, "msg")==true) recvmsg = ds_map_find_value(dsMap, "msg"); else recvmsg = "default";
        if (ds_map_exists(dsMap, "srcname")==true) recvname = ds_map_find_value(dsMap, "srcname"); else recvname = "?";
        if (ds_map_exists(dsMap, "srcport")==true) recvpubport = real(ds_map_find_value(dsMap, "srcname")); else recvpubport = 0;
        if (ds_map_exists(dsMap, "srctype")==true) recvpubtype = ds_map_find_value(dsMap, "srctype"); else recvpubtype = "default";
        if (ds_map_exists(dsMap, "typeid")==true) recvtypeid = ds_map_find_value(dsMap, "typeid"); else recvtypeid = "?";
        ds_map_add(dsMap, "ip", recvip);
        ds_map_add(dsMap, "port", recvport);
        ds_map_add(dsMap, "datastart", datastart);
        recvheaders = ds_map_write(dsMap);
        ds_map_destroy(dsMap);
    }
    
    
    //Add current peer in chain
    if (ds_list_find_index(net_peer_key, recvkey)<0 && recvkey!=net_key) {
        var pos = ds_list_find_index(net_peer_id, net_connect(net_vars, recvtype, recvip, recvport));
        if (ds_list_find_value(net_peer_name, pos)=="?") ds_list_replace(net_peer_name, pos, recvname);
        if (ds_list_find_value(net_peer_typeid, pos)=="?") ds_list_replace(net_peer_typeid, pos, recvtypeid);

    }
    
    //Quit when no message provided
    if (ds_list_size(recvlist)==datastart) return 1;
}

//Discard when known
var hashstr = recvtokey+recvtime;
for (i=datastart; i<ds_list_size(recvlist); i++) {
    hashstr += ds_list_find_value(recvlist, i);
}
recvhash = sha1_string_unicode(hashstr);

if (ds_list_find_index(net_msglist, recvhash)>=0) {
    return 1;
} else {
    ds_list_add(net_msglist, recvhash);
}

//To be forwarded
if (recvtokey=="-1" && recvtype!="NET_BROADCAST") return 1;
if (recvtokey!=net_key && recvtokey!="-1") {
    var fwdlist = ds_list_create();
    ds_list_copy(fwdlist, recvlist);
    ds_list_insert(fwdlist, 0, recvip);
    ds_list_insert(fwdlist, 1, recvport);
    if (ds_list_find_index(net_peer_key, recvtokey)==-1 || ds_list_find_index(net_peer_key, recvkey)<0) {
        for (var i=0; i<ds_list_size(net_peer_key); i++) {
            net_send(net_vars, ds_list_find_value(net_peer_id, i), "MSG_FORWARD", fwdlist);
        }
    } else {
        net_send(net_vars, recvtokey, recvmsg, recvlist);
    }
    ds_list_destroy(fwdlist);
    return 1;
}

switch (recvmsg) {
    case "MSG_CONN":
        ///SERVER
        datalist = ds_list_create();
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        net_send(net_vars, ds_list_find_value(net_peer_id, pos), "MSG_INFO", datalist);
        return 1;
        
    case "MSG_DISCONN":
        ///SERVER
        net_disconnect(net_vars, recvkey);
        return 1;
        
    case "MSG_PING":
        ///SERVER
        datalist = ds_list_create();
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        ds_list_add(datalist, ds_list_find_value(recvlist, datastart));
        net_send(net_vars, ds_list_find_value(net_peer_id, pos), "MSG_PONG", datalist);
        ds_list_destroy(datalist);
        return 1;
        
    case "MSG_PONG":
        ///CLIENT
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        ds_list_replace(net_peer_ping, pos, round((get_timer()-real(ds_list_find_value(recvlist, datastart)))/1000));
        ds_list_replace(net_peer_pingrecv, pos, get_timer());
        return 1;
        
    case "MSG_INFO":
        ///CLIENT
        return 1;
        
    case "MSG_LANPEERREQ":
        ///SERVER
        var transfer_key, transfer_ip, transfer_port, transfer_name, transfer_nettype, transfer_typeid;
        if (recvtype!="NET_BROADCAST") return 1;
        transfer_key = ds_list_create();
        transfer_ip = ds_list_create();
        transfer_port = ds_list_create();
        transfer_name = ds_list_create();
        transfer_nettype = ds_list_create();
        transfer_typeid = ds_list_create();
        for (var i=0; i<ds_list_size(net_peer_id); i++) {
            if (ds_list_find_value(net_peer_lan, i)==true) {
                ds_list_add(transfer_key, ds_list_find_value(net_peer_key, i));
                ds_list_add(transfer_ip, ds_list_find_value(net_peer_ip, i));
                ds_list_add(transfer_port, ds_list_find_value(net_peer_port, i));
                ds_list_add(transfer_name, ds_list_find_value(net_peer_name, i));
                ds_list_add(transfer_nettype, ds_list_find_value(net_peer_nettype, i));
                ds_list_add(transfer_typeid, ds_list_find_value(net_peer_typeid, i));
            }
        }
        
        datalist = ds_list_create();
        ds_list_add(datalist, ds_list_write(transfer_key));
        ds_list_add(datalist, ds_list_write(transfer_ip));
        ds_list_add(datalist, ds_list_write(transfer_port));
        ds_list_add(datalist, ds_list_write(transfer_name));
        ds_list_add(datalist, ds_list_write(transfer_nettype));
        ds_list_add(datalist, ds_list_write(transfer_typeid));
        
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        net_send(net_vars, ds_list_find_value(net_peer_id, pos), "MSG_LANPEER", datalist);
        
        ds_list_destroy(datalist);
        ds_list_destroy(transfer_key);
        ds_list_destroy(transfer_ip);
        ds_list_destroy(transfer_port);
        ds_list_destroy(transfer_name);
        ds_list_destroy(transfer_nettype);
        ds_list_destroy(transfer_typeid);
        return 1;
        
    case "MSG_LANPEER":
        ///CLIENT
        var transfer_key, transfer_ip, transfer_port, transfer_name, transfer_nettype, transfer_typeid;
        var recvid, lanid;
        recvid = ds_list_find_index(net_peer_socket, recvsocket);
        lanid = ds_list_find_index(net_peer_id, net_devicemasterid);
        if (lanid<0) {
            net_devicemasterid = -1;
            ds_map_replace(net_vars, "net_devicemasterid", net_devicemasterid);
        }
        if (net_devicemasterid<0) {
            net_devicemasterid = ds_list_find_value(net_peer_id, recvid);
            ds_map_replace(net_vars, "net_devicemasterid", net_devicemasterid);
        } else {
            if (net_devicemasterid!=recvid) return 1;
        }
        
        transfer_key = ds_list_create();
        transfer_ip = ds_list_create();
        transfer_port = ds_list_create();
        transfer_name = ds_list_create();
        transfer_nettype = ds_list_create();
        transfer_typeid = ds_list_create();
        
        ds_list_read(transfer_key, ds_list_find_value(recvlist, datastart));
        ds_list_read(transfer_ip, ds_list_find_value(recvlist, datastart+1));
        ds_list_read(transfer_port, ds_list_find_value(recvlist, datastart+2));
        ds_list_read(transfer_name, ds_list_find_value(recvlist, datastart+3));
        ds_list_read(transfer_nettype, ds_list_find_value(recvlist, datastart+4));
        ds_list_read(transfer_typeid, ds_list_find_value(recvlist, datastart+5));
        
        var pos = ds_list_find_index(transfer_key, net_key);
        if (pos>=0) {
            ds_list_delete(transfer_key, pos);
            ds_list_delete(transfer_ip, pos);
            ds_list_delete(transfer_port, pos);
            ds_list_delete(transfer_name, pos);
            ds_list_delete(transfer_nettype, pos);
            ds_list_delete(transfer_typeid, pos);
        }
        
        for (var i=0; i<ds_list_size(transfer_key); i++) {
            if (ds_list_find_index(net_lan_key, ds_list_find_value(transfer_key, i))<0) {
                var nettype, ip, port, pos;
                nettype = ds_list_find_value(transfer_nettype, i);
                ip = ds_list_find_value(transfer_ip, i);
                port = ds_list_find_value(transfer_port, i);
                pos = net_connect(net_vars,nettype,ip,port);
                ds_list_replace(net_peer_key, pos, ds_list_find_value(transfer_port, i));
                ds_list_replace(net_peer_name, pos, ds_list_find_value(transfer_name, i));
                ds_list_replace(net_peer_typeid, pos, ds_list_find_value(transfer_typeid, i));
                show_debug_message("Added peer on "+ip+":"+string(port));
            }
        }
        
        ds_list_destroy(transfer_key);
        ds_list_destroy(transfer_ip);
        ds_list_destroy(transfer_port);
        ds_list_destroy(transfer_name);
        ds_list_destroy(transfer_nettype);
        ds_list_destroy(transfer_typeid);
        return 1;
        
    default:
        var dsMap = ds_map_create();
        ds_map_read(dsMap, recvheaders);
        return -dsMap;
}
