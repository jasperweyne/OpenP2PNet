///netcommand(netInst,time,command,argument0,argument1,etc.)
/***********************
** AVAILABLE COMMANDS **
************************
**
** CMD_PING; ID
** CMD_DISCONN; ID
**
*/
var net_vars = argument[0];
var net_cmdlist;
net_cmdlist = ds_map_find_value(net_vars, "net_cmdlist");

if (argument_count>=3) {
    var list;
    list = ds_list_create();
    for (var i=2; i<argument_count; i++) ds_list_add(list, argument[i]);
    ds_list_add(net_cmdlist, list);
    ds_list_add(net_cmdlist, argument[1]);
}
