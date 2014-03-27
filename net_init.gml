///net_init(name,key,port,connectiontype,interval,maxpeers,compatible);
var net_vars;
var net_name, net_key, net_lanport, net_pubport, net_pubtype, net_interval, net_maxpeers, net_compatible;
var net_peer_id, net_peer_key, net_peer_ip, net_peer_port, net_peer_nettype, net_peer_name, net_peer_ping, net_peer_lastping, net_peer_pingrecv, net_peer_type, net_peer_socket, net_peer_typeid;
var net_cmdlist, net_msglist, net_idcounter;
var net_devicemaster, net_devicemasterid, net_lanserver, net_pubserver, net_timer;

net_name = argument0;
net_key = argument1;
net_lanport = 6510;
net_pubport = argument2;
net_interval = argument4;
net_maxpeers = argument5;
net_compatible = string(game_id)+";"+argument6;

//Serverlists
net_peer_id = ds_list_create();         //Local ID of the clien
net_peer_key = ds_list_create();        //Key: unique ID of the client
net_peer_ip = ds_list_create();         //IP
net_peer_port = ds_list_create();       //Port
net_peer_nettype = ds_list_create();    //Nettype: type of connection (NET_*: UDP, TCP, BROADCAST, HTTP)
net_peer_name = ds_list_create();       //Name: Human-readable ID of the client
net_peer_ping = ds_list_create();       //Last ping time: time to receive an answer of an "empty" package
net_peer_lastping = ds_list_create();   //Last time a ping was sent
net_peer_pingrecv = ds_list_create();   //Last time a ping answer was received
net_peer_type = ds_list_create();       //Type of connection (NETTYPE_*: LAN, EXT, PEER)
net_peer_socket = ds_list_create();     //Socket ID of the connection
net_peer_typeid = ds_list_create();     //GameID

net_idcounter = 0;
net_timer = 0;

//Commands
net_cmdlist = ds_list_create();

//Recieved message hashes
net_msglist = ds_list_create();

net_vars = ds_map_create()
ds_map_add(net_vars, "net_name", net_name);
ds_map_add(net_vars, "net_key", net_key);
ds_map_add(net_vars, "net_lanport", net_lanport);
ds_map_add(net_vars, "net_interval", net_interval);
ds_map_add(net_vars, "net_maxpeers", net_maxpeers);
ds_map_add(net_vars, "net_compatible", net_compatible);
ds_map_add(net_vars, "net_peer_id", net_peer_id);
ds_map_add(net_vars, "net_peer_key", net_peer_key);
ds_map_add(net_vars, "net_peer_ip", net_peer_ip);
ds_map_add(net_vars, "net_peer_port", net_peer_port);
ds_map_add(net_vars, "net_peer_nettype", net_peer_nettype);
ds_map_add(net_vars, "net_peer_name", net_peer_name);
ds_map_add(net_vars, "net_peer_ping", net_peer_ping);
ds_map_add(net_vars, "net_peer_lastping", net_peer_lastping);
ds_map_add(net_vars, "net_peer_pingrecv", net_peer_pingrecv);
ds_map_add(net_vars, "net_peer_type", net_peer_type);
ds_map_add(net_vars, "net_peer_socket", net_peer_socket);
ds_map_add(net_vars, "net_peer_typeid", net_peer_typeid);
ds_map_add(net_vars, "net_cmdlist", net_cmdlist);
ds_map_add(net_vars, "net_msglist", net_msglist);
ds_map_add(net_vars, "net_idcounter", net_idcounter);           //R/W
ds_map_add(net_vars, "net_timer", net_timer);                   //R/W

//LAN
net_devicemaster = true;
net_devicemasterid = -1;
net_lanserver = network_create_server(network_socket_udp, net_lanport, net_maxpeers);
if (net_lanserver<0) {
    while (net_devicemasterid<0) net_devicemasterid = net_connect(net_vars, NET_UDP, "127.0.0.1", 6510);
    net_devicemaster = false;
    while (net_lanserver<0) {
        net_lanport++;
        net_lanserver = network_create_server(network_socket_udp, net_lanport, net_maxpeers);
    }
}

//Public
switch (argument3) {
    case network_socket_tcp:
        net_pubtype = NET_TCP;
        net_pubserver = network_create_server(network_socket_tcp, net_pubport, net_maxpeers);
        break;
    case network_socket_udp:
    default:
        net_pubtype = NET_UDP;
        net_pubserver = network_create_server(network_socket_udp, net_pubport, net_maxpeers);
        break;
}   

ds_map_add(net_vars, "net_devicemaster", net_devicemaster);
ds_map_add(net_vars, "net_devicemasterid", net_devicemasterid);
ds_map_add(net_vars, "net_lanserver", net_lanserver);
ds_map_add(net_vars, "net_pubserver", net_pubserver);
ds_map_add(net_vars, "net_pubport", net_pubport);
ds_map_add(net_vars, "net_pubtype", net_pubtype);
ds_map_replace(net_vars, "net_lanport", net_lanport);

return net_vars;
