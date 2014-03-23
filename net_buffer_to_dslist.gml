///net_buffer_to_dslist(buffer,ds_list)
var size = buffer_get_size(argument0);
var buffer = buffer_create(size, buffer_fixed, 1);
buffer_copy(argument0, 0, size, buffer, 0);
var list = argument1;

buffer_seek(buffer, buffer_seek_start, 0);
while (buffer_tell(buffer)<size) {
    var val = buffer_read(buffer, buffer_string);
    if (val!="") ds_list_add(list, val);
}

buffer_delete(buffer);

return list;
