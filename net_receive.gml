///net_receive(eventtype,ds_list,ip,port,socket)
/******************
** RETURN VALUES **
*******************
**   1: Message correctly handled
**   0: Error
**  -1: Unknown protocol
**  -2: OPENP2PNET implementation is outdated
** any: Unknown OPENP2PNET Message, return value is message type
*/
globalvar net_vars;
var net_key;
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_type, net_peer_socket;
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
net_peer_type =         ds_map_find_value(net_vars, "net_peer_type");
net_peer_socket =       ds_map_find_value(net_vars, "net_peer_socket");
net_msglist =           ds_map_find_value(net_vars, "net_msglist");
net_idcounter =         ds_map_find_value(net_vars, "net_idcounter");
net_lanserver =         ds_map_find_value(net_vars, "net_lanserver");
net_pubserver =         ds_map_find_value(net_vars, "net_pubserver");
var recvlist, recvip, recvport, recvsocket, recvmsg, recvtype, recvkey, recvname, recvtokey, recvsignature, recvtime, recvhash, datalist, datastart;

recvlist = argument1;
if (string_copy(ds_list_find_value(recvlist, 0), 1, 12)!="[OPENP2PNET]") return -1;
if (string_delete(ds_list_find_value(recvlist, 0), 1, 12)!="[v0.1.0.0]") return -2;
recvip = argument2;
recvport = argument3;
recvsocket = argument4;
recvmsg = real(ds_list_find_value(recvlist, 1));
recvtype = real(ds_list_find_value(recvlist, 2));
recvkey = ds_list_find_value(recvlist, 3);
recvname = ds_list_find_value(recvlist, 4);
recvsignature = ds_list_find_value(recvlist, 5);
recvtokey = ds_list_find_value(recvlist, 6);
recvtime = ds_list_find_value(recvlist, 7);
datastart = 8;

//Check signature
//pass

//(Dis)connections
switch (recvtype) {
    case NET_TCP:
    case NET_TCPRAW:
        if (argument0!=network_type_data) {
            if (argument0==network_type_connect) {
                //Connect
                net_idcounter++;
                ds_map_replace(net_vars, "net_idcounter", net_idcounter);
                ds_list_add(net_peer_id, net_idcounter);
                ds_list_add(net_peer_key, "?");
                ds_list_add(net_peer_ip, recvip);
                ds_list_add(net_peer_port, recvport);
                ds_list_add(net_peer_nettype, NET_TCP); //Since you can't run a raw server, and all other protocols are connectionless, it must be built-in TCP
                ds_list_add(net_peer_name, "?");
                ds_list_add(net_peer_ping, 0);
                ds_list_add(net_peer_lastping, 0);
                ds_list_add(net_peer_pingrecv, 0);
                ds_list_add(net_peer_type, NETTYPE_PEER);
                ds_list_add(net_peer_socket, recvsocket);
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
                ds_list_delete(net_peer_type, pos);
                ds_list_delete(net_peer_socket, pos);
            }
            return 1;
        } else {
            var pos = ds_list_find_index(net_peer_socket, recvsocket);
            if (pos>=0) {
                if (string_copy(ds_list_find_value(net_peer_key, pos), 1, 1)=="?") ds_list_replace(net_peer_key, pos, recvkey);
                if (ds_list_find_value(net_peer_name, pos)=="?") ds_list_replace(net_peer_name, pos, recvname);
            }
        }
        break;
    case NET_UDP:
        if (recvsocket==net_lanserver || recvsocket==net_pubserver) {
            //Connect (Src: incoming)
            var socket = -1;
            while (socket<0) socket = network_create_socket(network_socket_udp);
            recvsocket = socket;
            net_idcounter++;
            ds_map_replace(net_vars, "net_idcounter", net_idcounter);
            ds_list_add(net_peer_id, net_idcounter);
            ds_list_add(net_peer_key, recvkey);
            ds_list_add(net_peer_ip, recvip);
            ds_list_add(net_peer_port, recvport);
            ds_list_add(net_peer_nettype, NET_UDP);
            ds_list_add(net_peer_name, recvname);
            ds_list_add(net_peer_ping, 0);
            ds_list_add(net_peer_lastping, 0);
            ds_list_add(net_peer_pingrecv, 0);
            ds_list_add(net_peer_type, NETTYPE_PEER);
            ds_list_add(net_peer_socket, recvsocket);
        } else if (ds_list_find_value(net_peer_key, ds_list_find_index(net_peer_socket, recvsocket))=="?") {
            //Connect (Src: outgoing)
            var pos = ds_list_find_index(net_peer_socket, recvsocket);
            ds_list_replace(net_peer_key, pos, recvkey);
            ds_list_replace(net_peer_name, pos, recvname);
        }
        break;
}

//Modify vars when forwared message
while (recvmsg==MSG_FORWARD) {
    recvip = ds_list_find_value(recvlist, datastart);
    recvport = real(ds_list_find_value(recvlist, datastart+1));
    if (string_copy(ds_list_find_value(recvlist, datastart+2), 1, 12)!="[OPENP2PNET]") return -1;
    if (string_delete(ds_list_find_value(recvlist, datastart+2), 1, 12)!="[v0.1.0.0]") return -2;
    recvmsg = real(ds_list_find_value(recvlist, datastart+3));
    recvtype = real(ds_list_find_value(recvlist, datastart+4));
    recvkey = ds_list_find_value(recvlist, datastart+5);
    recvname = ds_list_find_value(recvlist, datastart+6);
    recvsignature = ds_list_find_value(recvlist, datastart+7);
    recvtokey = ds_list_find_value(recvlist, datastart+8);
    recvtime = ds_list_find_value(recvlist, datastart+9);
    datastart += 10;
    
    //Add current peer in chain
    if (ds_list_find_index(net_peer_key, recvkey)<0) net_connect(recvtype, recvip, recvport);
    
    //Quit when no message provided
    if (ds_list_size(recvlist)==datastart) return 1;
}

//Discard when known
var hashstr = "";
for (i=datastart-2; i<ds_list_size(recvlist); i++) {
    hashstr += ds_list_find_value(recvlist, i);
}
recvhash = sha1_string_unicode(hashstr);

if (ds_list_find_index(net_msglist, recvhash)>=0) {
    return 1;
} else {
    ds_list_add(net_msglist, recvhash);
}

//To be forwarded
if (recvtokey!=net_key && recvtokey!="-1") {
    var fwdlist = ds_list_create();
    ds_list_copy(fwdlist, recvlist);
    ds_list_insert(fwdlist, 0, recvip);
    ds_list_insert(fwdlist, 1, recvport);
    if (ds_list_find_index(net_peer_key, recvtokey)==-1 || ds_list_find_index(net_peer_key, recvkey)<0) {
        for (var i=0; i<ds_list_size(net_peer_key); i++) {
            net_send(ds_list_find_value(net_peer_id, i), MSG_FORWARD, fwdlist);
        }
    } else {
        net_send(recvtokey, recvmsg, recvlist);
    }
    ds_list_destroy(fwdlist);
    return 1;
}

switch (recvmsg) {
    case MSG_CONN:
        ///SERVER
        return 1;
        
    case MSG_DISCONN:
        ///SERVER
        net_disconnect(recvkey);
        return 1;
        
    case MSG_PING:
        ///SERVER
        datalist = ds_list_create();
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        ds_list_add(datalist, ds_list_find_value(recvlist, datastart));
        net_send(ds_list_find_value(net_peer_id, pos), MSG_PONG, datalist);
        ds_list_destroy(datalist);
        return 1;
        
    case MSG_PONG:
        ///CLIENT
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        ds_list_replace(net_peer_ping, pos, round((get_timer()-real(ds_list_find_value(recvlist, datastart)))/1000));
        ds_list_replace(net_peer_pingrecv, pos, get_timer());
        return 1;
        
    case MSG_INFOREQUEST:
        ///SERVER
        datalist = ds_list_create();
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        net_send(ds_list_find_value(net_peer_id, pos), MSG_INFO, datalist);
        ds_list_destroy(datalist);
        return 1;
        
    case MSG_INFO:
        ///CLIENT
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        ds_list_replace(net_peer_type, pos, NETTYPE_EXT);
        return 1;
        
    case MSG_PEERREQUEST:
        ///SERVER
        var transfer_key, transfer_ip, transfer_port, transfer_nettype;
        transfer_key = ds_list_create();
        ds_list_copy(transfer_key, net_peer_key);
        transfer_ip = ds_list_create();
        ds_list_copy(transfer_ip, net_peer_ip);
        transfer_port = ds_list_create();
        ds_list_copy(transfer_port, net_peer_port);
        transfer_nettype = ds_list_create();
        ds_list_copy(transfer_nettype, net_peer_nettype);
        
        datalist = ds_list_create();
        ds_list_add(datalist, ds_list_write(transfer_key));
        ds_list_add(datalist, ds_list_write(transfer_ip));
        ds_list_add(datalist, ds_list_write(transfer_port));
        ds_list_add(datalist, ds_list_write(transfer_nettype));
        pos = ds_list_find_index(net_peer_socket, recvsocket);
        net_send(ds_list_find_value(net_peer_id, pos), MSG_PEERTRANSFER, datalist);
        ds_list_destroy(datalist);
        ds_list_destroy(transfer_key);
        ds_list_destroy(transfer_ip);
        ds_list_destroy(transfer_port);
        ds_list_destroy(transfer_nettype);
        return 1;
        
    case MSG_PEERTRANSFER:
        ///CLIENT
        var transfer_key, transfer_ip, transfer_port, transfer_nettype;
        transfer_key = ds_list_create();
        transfer_ip = ds_list_create();
        transfer_port = ds_list_create();
        transfer_type = ds_list_create();
        
        ds_list_read(transfer_key, ds_list_find_value(recvlist, datastart));
        ds_list_read(transfer_ip, ds_list_find_value(recvlist, datastart+1));
        ds_list_read(transfer_port, ds_list_find_value(recvlist, datastart+2));
        ds_list_read(transfer_nettype, ds_list_find_value(recvlist, datastart+3));
        
        pos = ds_list_find_index(transfer_key, net_key);
        ds_list_delete(transfer_key, pos);
        ds_list_delete(transfer_ip, pos);
        ds_list_delete(transfer_port, pos);
        ds_list_delete(transfer_nettype, pos);
        
        for (var i=0; i<ds_list_size(transfer_key); i++) {
            if (ds_list_find_index(net_lan_key, ds_list_find_value(lantransfer_key, i))<0) {
                var nettype, ip, port;
                nettype = ds_list_find_value(transfer_nettype, i);
                ip = ds_list_find_value(transfer_ip, i);
                port = ds_list_find_value(transfer_port, i);
                net_connect(nettype,ip,port);
                show_debug_message("Added peer on "+ip+":"+string(port));
            }
        }
        
        ds_list_destroy(transfer_key);
        ds_list_destroy(transfer_ip);
        ds_list_destroy(transfer_port);
        ds_list_destroy(transfer_nettype);
        return 1;
        
    default:
        return recvmsg;
}
