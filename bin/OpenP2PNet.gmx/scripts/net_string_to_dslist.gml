///net_string_to_dslist(string,ds_list)
var str_ = argument0;
var listnlchr = false;
var list = argument1;
ds_list_add(list, "");

for (var i=1; i<=string_length(str_); i++) {
    var char = string_char_at(str_, i);
    if (char==chr(10)) {
        if (listnlchr==true) break;
        listnlchr = true;
        ds_list_add(list, "");
    } else {
        listnlchr = false;
        var pos = ds_list_size(list)-1;
        ds_list_replace(list, pos, ds_list_find_value(list, pos)+char);
    }
}
ds_list_delete(list, ds_list_size(list)-1);
return list;
