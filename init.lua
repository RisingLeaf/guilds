local modname = "guilds"

storage = minetest.get_mod_storage()
if minetest.deserialize(storage:get_string("guilds")) == nil then
    storage:set_string("guilds", minetest.serialize({}))
end

dofile(minetest.get_modpath(modname) .. "/functions.lua")
dofile(minetest.get_modpath(modname) .. "/chatcmdbuilder.lua")

function guild_message(guild, name, message, color)
    for key,value in pairs(guild) do
        minetest.chat_send_player(key, minetest.colorize(color, "g<" .. name .. "> " .. message))
    end    
end

minetest.register_privilege("guild_priv", {
    description = "Can create a guild",
    give_to_singleplayer = true
})

minetest.register_chatcommand("create_guild", {
    privs = {
        guild_priv = true,
    },
    func = function(name, param)
        local guilds = minetest.deserialize(storage:get_string("guilds"))
        local player = minetest.get_player_by_name(name)
        local guild_name = get_player_attribute(name, "guild")
        if guild_name ~= nil then
            minetest.chat_send_player(name, "You are already in the guild " .. guild_name .. ". For more information type '/my_guild'.")
            return false
        elseif guilds[param] ~= nil then
            minetest.chat_send_player(name, "This Guild does already exist. The leader is: " .. guilds[param])
            return false
        else
            set_player_attrib(name, "guild", param)
            guilds[param] = name
            local guild = {}
            guild[name] = 10
            storage:set_string("guilds", minetest.serialize(guilds))
            storage:set_string(param, minetest.serialize(guild))
            minetest.chat_send_all("The Guild " .. param .. " was created. The leader is: " .. name)
            return true, "You are rank 10 in the guild " .. param .. "!"
        end
    end,
})

minetest.register_chatcommand("my_guild", {
    privs = {},
    func = function(name, param)
        local player     = minetest.get_player_by_name(name)
        local guild_name = get_player_attribute(name, "guild")
        if guild_name ~= nil then
            local guilds     = minetest.deserialize(storage:get_string("guilds"))
            local guild      = minetest.deserialize(storage:get_string(guild_name))
            local leader     = guilds[guild_name]
            local rank       = guild[name]
            minetest.chat_send_player(name, "You are rank " .. rank .. " in the guild " .. guild_name .. ". Your leader is " .. leader .. ".")
        else
            minetest.chat_send_player(name, "You are not in a guild.")
        end
        return true
    end,
})

minetest.register_chatcommand("join_guild", {
    privs = {},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local guild_name = get_player_attribute(name, "guild")
        local guilds = minetest.deserialize(storage:get_string("guilds"))
        if guilds[param] == nil then
            minetest.chat_send_player(name, "This Guild does not exist.")
            return false
        elseif guild_name ~= nil then
            minetest.chat_send_player(name, "You are already in the guild " .. guild_name .. ". For more information type '/my_guild'.")
            return false
        else
            set_player_attrib(name, "applying", param)
            minetest.deserialize(storage:get_string(guild_name))
            guild_message(guild, "server", name .. "Wants to join your Guild!", "#0d18f3")
        end
    end,
})

minetest.register_chatcommand("accept", {
    privs = {},
    func = function(name, param)
        local player_applying = minetest.get_player_by_name(param)
        if player_applying ~= nil then
            local player          = minetest.get_player_by_name(name)
            local guild_name      = get_player_attribute(name, "guild")
            if guild_name ~= nil then
                local guild           = minetest.deserialize(storage:get_string(guild_name))
                local applied_guild   = get_player_attribute(param, "applying")
                if applied_guild == guild_name then
                    if guild[name] >= 5 then
                        set_player_attrib(param, "guild", guild_name)
                        guild[param] = 1
                        storage:set_string(guild_name, minetest.serialize(guild))
                        minetest.chat_send_player(param, "You were accepted to the guild " .. guild_name .. " with rank 1!")
                        guild_message(guild, param, param .. "joined the guild with rank 1", "#0d18f3")
                    else
                        minetest.chat_send_player(name, "Your rank is not high enough to accept other players to the guild!")
                    end
                else
                    minetest.chat_send_player(name, "This player dont want to join your guild!")
                end
            else
                minetest.chat_send_player(name, "You are not in a guild!")
            end
        else
            minetest.chat_send_player(name, "This player does not exist!")
        end
    end,
})

minetest.register_chatcommand("leave_guild", {
    privs = {},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local guild_name = get_player_attribute(name "guild")
        if guild_name ~= nil then
            local guild = storage:get_string(guild_name)
            if guild[name] ~= 10 then
                guild_message(guild, name, name .. "leaved the guild!", "#f33df0")
                guild[name] = nil
                set_player_attrib(name, "guild", nil)
                storage:set_string(guild_name, minetest.serialize(guild))
            else
                minetest.chat_send_player(name, "You are the leader of this guild. Promote someone else to leader!")
            end
        else
            minetest.chat_send_player(name, "You are not in a guild!")
        end
    end,
})

minetest.register_chatcommand("gm", {
    privs = {shout = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local guild_name = get_player_attribute(name, "guild")
        if guild_name ~= nil then
            local guild = minetest.deserialize(storage:get_string(guild_name))
            guild_message(guild, name, param, "#15f312")
        else
            minetest.chat_send_player(name, "You are not in a guild!")
        end
    end
})

minetest.register_chatcommand("declare_war", {
    privs = {shout = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local guild_name = get_player_attribute(name, "guild")
        if guild_name ~= nil then
            local player_guild = minetest.deserialize(storage:get_string(guild_name))
            local guilds = minetest.deserialize(storage:get_string("guilds"))
            if guilds[param] ~= nil then
                local rank = player_guild[name]
                if rank >= 8 then
                    local war_guild = minetest.deserialize(storage:get_string(param))
                    guild_message(war_guild, name, "The Guild " .. guild_name .. " declared war to you. Come to the PvP Arena!", "#f30004")
                    guild_message(player_guild, name, "We declared war to " .. param .. ". Come to the PvP Arena.", "#f30004")
                else
                    minetest.chat_send_player(name, "You have to be rank 8 to declare war.")
                end
            else
                minetest.chat_send_player(name, "This guild does not exist!")
            end
        else
            minetest.chat_send_player(name, "You are not part of a guild!")
        end
    end
})

ChatCmdBuilder.new("promote", function(cmd)
    cmd:sub(":target :to_rank:int", 
    function(name, target, to_rank)
        local player = minetest.get_player_by_name(name)
        local guild_name = get_player_attribute(name, "guild")
        if guild_name ~= nil then
            local guild = minetest.deserialize(storage:get_string(guild_name))
            if guild[target] ~= nil then
                local player_rank = guild[name]
                local promote_rank = guild[target]
                if promote_rank < player_rank and player_rank > to_rank then
                    guild[target] = to_rank
                    storage:set_string(guild_name, minetest.serialize(guild))
                    minetest.chat_send_player(target, "You were promted to rank 7!")
                else
                    minetest.chat_send_player(name, "Your rank is not high enough to do this!")
                end
            else
                minetest.chat_send_player(name, "This player is not in your guild!")
            end
        else
            minetest.chat_send_player(name, "You are not in a guild!")
        end
    end)
end, {
    description = "Promote player to rank ...",
    privs = {
    }
})



minetest.register_chatcommand("list_guilds", {
    privs = {},
    func = function(name, param)
        local guilds = minetest.deserialize(storage:get_string("guilds"))
        minetest.chat_send_player(name, minetest.serialize(guilds))
    end,
})



function get_formspec(name)
    local formspec = {}

    local player = minetest.get_player_by_name(name)
    local guild_name = get_player_attribute(name, "guild")
    if guild_name ~= nil then
        local guild = minetest.deserialize(storage:get_string(guild_name))
        local guilds     = minetest.deserialize(storage:get_string("guilds"))
        local leader     = guilds[guild_name]
        local rank       = guild[name]
        
        local player_list_string = ""
        for key, value in pairs(guild) do
            player_list_string = player_list_string .. key .. ","
        end
        player_list_string = player_list_string:sub(1, -2)
                
        formspec = {
            "size[14.01,8.79]",
            "label[6.1,-0.33;Guild Menu]",
            "label[-0.3,0.11;" .. "You are rank " .. rank .. " in the guild " .. guild_name .. ". Your leader is " .. leader .. "." .. "]",
            "image_button_exit[11.5,8.34;2.61,0.78;blank.png;back;Back]",
            
            "textlist[0.1,0.76;7.2,7.81;members;" .. player_list_string .. ";1;false]",
            
            "image_button[7.7,0.76;2.61,0.78;blank.png;promote;Promote]",
            "field[8.0,2.21;2.6,0.82;chat;Chat;Hi all]",
            "image_button[10.9,1.93;2.61,0.78;blank.png;send;Send]",
        }
    else    
        formspec = {
            "size[14.01,8.79]",
            "label[6.1,-0.33;Guild Menu]",
            "image_button_exit[11.5,8.34;2.61,0.78;blank.png;back;Back]",
            "label[-0.22,-0.07;You are not in a guild!]",
            "field[6.0,4.08;2.6,0.82;guild_name;Guild you want to join:;]",
            "image_button[5.7,4.66;2.61,0.78;blank.png;send;Send Request]"
        }
    end

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

function show_to(name)
    minetest.chat_send_all(name)
    if name ~= nil then
        minetest.show_formspec(name, "guilds:menu", get_formspec(name))
    end
end

minetest.register_chatcommand("guilds_menu", {
    func = function(name)
        show_to(name)
    end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local guild_name = get_player_attribute(name, "guild")
	if formname == "guilds:menu" then
        if fields["send"] ~= nil then
            local guild = minetest.deserialize(storage:get_string(guild_name))
            guild_message(guild, name, fields["chat"], "#15f312")
        end
	end
end)


