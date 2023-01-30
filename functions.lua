function set_player_attrib(player_name, attrib, value)
    local player_array = minetest.deserialize(storage:get_string(player_name))
    if player_array == nil then
        player_array = {}
    end
    player_array[attrib] = value
    storage:set_string(player_name, minetest.serialize(player_array))
end

function get_player_attribute(player_name, attrib)
    local player_array = minetest.deserialize(storage:get_string(player_name))
    if player_array == nil then
        return nil
    end
    return player_array[attrib]
end