///netcommand(command,argument0,argument1,etc.)
/***********************
** AVAILABLE COMMANDS **
************************
**
** CMD_PING; ID
**
**
*/
globalvar net_vars;
var net_cmds;
net_cmds =              ds_map_find_value(net_vars, "net_cmds");
if (argument_count>=1) {
    var list;
    list = ds_list_create();
    for (var i=0; i<argument_count; i++) ds_list_add(list, argument[i]);
    ds_list_add(net_cmds, list);
}
