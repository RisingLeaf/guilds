function set_player_attrib(player_name, attrib, value)
	local meta = minetest.get_player_by_name(player_name):get_meta()
	meta:set_string(attrib, minetest.serialize(value))
end

function get_player_attribute(player_name, attrib)
	local meta = minetest.get_player_by_name(player_name):get_meta()
	return minetest.deserialize(meta:get_string(attrib))
end