-- data saved to moderation.json
-- check moderation plugin
do
 
local function create_group(msg)
        -- superuser and admins only (because sudo are always has privilege)
        if is_sudo(msg) or is_realm(msg) and is_admin(msg) then
                local group_creator = msg.from.print_name
        create_group_chat (group_creator, group_name, ok_cb, false)
                return 'Il gruppo '..string.gsub(group_name, '_', ' ')..' è stato creato.'
        end
end
 
local function set_description(msg, data, target, about)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local data_cat = 'description'
        data[tostring(target)][data_cat] = about
        save_data(_config.moderation.data, data)
        return 'Descrizione impostata:\n'..about
end
 
local function set_rules(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local data_cat = 'rules'
        data[tostring(target)][data_cat] = rules
        save_data(_config.moderation.data, data)
        return 'Regole impostate:\n'..rules
end
-- lock/unlock group name. bot automatically change group name when locked
local function lock_group_name(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local group_name_set = data[tostring(target)]['settings']['set_name']
    local group_name_lock = data[tostring(target)]['settings']['lock_name']
        if group_name_lock == 'yes' then
            return 'Nome già bloccato'
        else
            data[tostring(target)]['settings']['lock_name'] = 'yes'
                save_data(_config.moderation.data, data)
                rename_chat('chat#id'..target, group_name_set, ok_cb, false)
        return 'Nome bloccato'
        end
end
 
local function unlock_group_name(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local group_name_set = data[tostring(target)]['settings']['set_name']
    local group_name_lock = data[tostring(target)]['settings']['lock_name']
        if group_name_lock == 'no' then
            return 'Nome già sbloccato'
        else
            data[tostring(target)]['settings']['lock_name'] = 'no'
            save_data(_config.moderation.data, data)
        return 'Nome sbloccato'
        end
end
--lock/unlock group member. bot automatically kick new added user when locked
local function lock_group_member(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
        if group_member_lock == 'yes' then
            return 'Membri già bloccati'
        else
            data[tostring(target)]['settings']['lock_member'] = 'yes'
            save_data(_config.moderation.data, data)
        end
        return 'Membri bloccati'
end
 
local function unlock_group_member(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
        if group_member_lock == 'no' then
            return 'Membri già sbloccati'
        else
            data[tostring(target)]['settings']['lock_member'] = 'no'
            save_data(_config.moderation.data, data)
        return 'Membri sbloccati'
        end
end
 
--lock/unlock group photo. bot automatically keep group photo when locked
local function lock_group_photo(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
        if group_photo_lock == 'yes' then
            return 'Foto già bloccata'
        else
            data[tostring(target)]['settings']['set_photo'] = 'waiting'
            save_data(_config.moderation.data, data)
        end
        return 'Inviami la nuova foto ora'
end
 
local function unlock_group_photo(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
        if group_photo_lock == 'no' then
            return 'Foto già sbloccata'
        else
            data[tostring(target)]['settings']['lock_photo'] = 'no'
            save_data(_config.moderation.data, data)
        return 'Foto sbloccata'
        end
end
 
local function lock_group_flood(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local group_flood_lock = data[tostring(target)]['settings']['flood']
        if group_flood_lock == 'yes' then
            return 'Flood già bloccato'
        else
            data[tostring(target)]['settings']['flood'] = 'yes'
            save_data(_config.moderation.data, data)
        return 'Flood bloccato'
        end
end
 
local function unlock_group_flood(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local group_flood_lock = data[tostring(target)]['settings']['flood']
        if group_flood_lock == 'no' then
            return 'Flood già sbloccato'
        else
            data[tostring(target)]['settings']['flood'] = 'no'
            save_data(_config.moderation.data, data)
        return 'Flood sbloccato'
        end
end
-- show group settings
local function show_group_settings(msg, data, target)
    if not is_admin(msg) then
        return "Solo per amministratori!"
    end
    local settings = data[tostring(target)]['settings']
    local text = "Impostazioni gruppo:\nBlocco nome: "..settings.lock_name.."\nBlocco foto: "..settings.lock_photo.."\nBlocco membri: "..settings.lock_member
    return text
end
 
local function returnids(cb_extra, success, result)
 
        local receiver = cb_extra.receiver
    local chat_id = "chat#id"..result.id
    local chatname = result.print_name
    local text = 'Users in '..string.gsub(chatname,"_"," ")..' ('..result.id..'):'..'\n'..''
    for k,v in pairs(result.members) do
        local username = ""
        text = text .. "- " .. string.gsub(v.print_name,"_"," ") .. "  (" .. v.id .. ") \n"
    end
    send_large_msg(receiver, text)
        local file = io.open("./groups/"..result.id.."memberlist.txt", "w")
        file:write(text)
        file:flush()
        file:close()
end
 
local function returnidsfile(cb_extra, success, result)
    local receiver = cb_extra.receiver
    local chat_id = "chat#id"..result.id
    local chatname = result.print_name
    local text = 'Utenti in '..string.gsub(chatname,"_"," ")..' ('..result.id..'):'..'\n'..''
    for k,v in pairs(result.members) do
        local username = ""
        text = text .. "- " .. string.gsub(v.print_name,"_"," ") .. "  (" .. v.id .. ") \n"
    end
        local file = io.open("./groups/"..result.id.."memberlist.txt", "w")
        file:write(text)
        file:flush()
        file:close()
        send_document("chat#id"..result.id,"./groups/"..result.id.."memberlist.txt", ok_cb, false)
end
 
local function admin_promote(msg, admin_id)
        if not is_sudo(msg) then
        return "Accesso negato!"
    end
        local data = load_data(_config.moderation.data)
        local admins = 'admins'
        if not data[tostring(admins)] then
                data[tostring(admins)] = {}
                save_data(_config.moderation.data, data)
        end
        if data[tostring(admins)][tostring(admin_id)] then
                return admin_name..' è già un amministratore.'
        end
        data[tostring(admins)][tostring(admin_id)] = admin_id
        save_data(_config.moderation.data, data)
        return admin_id..' è stato promosso ad amministratore.'
end
local function admin_demote(msg, admin_id)
    if not is_sudo(msg) then
        return "Accesso negato!"
    end
    local data = load_data(_config.moderation.data)
        local admins = 'admins'
        if not data[tostring(admins)] then
                data[tostring(admins)] = {}
                save_data(_config.moderation.data, data)
        end
        if not data[tostring(admins)][tostring(admin_id)] then
                return admin_id..' non è un amministratore.'
        end
        data[tostring(admins)][tostring(admin_id)] = nil
        save_data(_config.moderation.data, data)
        return admin_id..' ora non è più amministratore.'
end
 
local function admin_list(msg)
    local data = load_data(_config.moderation.data)
        local admins = 'admins'
        if not data[tostring(admins)] then
        data[tostring(admins)] = {}
        save_data(_config.moderation.data, data)
        end
        local message = 'Lista degli amministratori nel Realm:\n\n-sudo user-'
        for k,v in pairs(data[tostring(admins)]) do
                message = message .. '- @' .. v .. ' [' .. k .. '] ' ..'\n'
        end
        return message
end
 
local function group_list(msg)
    local data = load_data(_config.moderation.data)
        local groups = 'groups'
        if not data[tostring(groups)] then
                return 'Nessun gruppo al momento'
        end
        local message = 'Lista dei gruppi:\n'
        for k,v in pairs(data[tostring(groups)]) do
                local settings = data[tostring(v)]['settings']
                for m,n in pairs(settings) do
                        if m == 'set_name' then
                                name = n
                        end
                end
                local group_owner = "No owner"
                if data[tostring(v)]['set_owner'] then
                        group_owner = tostring(data[tostring(v)]['set_owner'])
                end
                local group_link = "No link"
                if data[tostring(v)]['settings']['set_link'] then
			group_link = data[tostring(v)]['settings']['set_link']
		end
                message = message .. '- '.. name .. ' (' .. v .. ') ['..group_owner..'] \n {'..group_link.."}\n"
        end
        local file = io.open("groups.txt", "w")
        file:write(message)
        file:flush()
        file:close()
        return message
end
local function admin_user_promote(receiver, member_username, member_id)
        local data = load_data(_config.moderation.data)
        if not data['admins'] then
                data['admins'] = {}
                save_data(_config.moderation.data, data)
        end
        if data['admins'][tostring(member_id)] then
                return send_large_msg(receiver, member_username..' è già amministratore.')
        end
        data['admins'][tostring(member_id)] = member_username
        save_data(_config.moderation.data, data)
        return send_large_msg(receiver, '@'..member_username..' è stato promosso ad amministratore.')
end
 
local function admin_user_demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
        if not data['admins'] then
                data['admins'] = {}
                save_data(_config.moderation.data, data)
        end
        if not data['admins'][tostring(member_id)] then
                return send_large_msg(receiver, member_username..' non è amministratore.')
        end
        data['admins'][tostring(member_id)] = nil
        save_data(_config.moderation.data, data)
        return send_large_msg(receiver, member_username..' da ora non è più amministratore.')
end
 
local function username_id(cb_extra, success, result)
   local mod_cmd = cb_extra.mod_cmd
   local receiver = cb_extra.receiver
   local member = cb_extra.member
   local text = 'Nessun @'..member..' in questo gruppo.'
   for k,v in pairs(result.members) do
      vusername = v.username
      if vusername == member then
        member_username = member
        member_id = v.id
        if mod_cmd == 'aggadmin' then
            return admin_user_promote(receiver, member_username, member_id)
        elseif mod_cmd == 'rimadmin' then
            return admin_user_demote(receiver, member_username, member_id)
        end
      end
   end
   send_large_msg(receiver, text)
end

function run(msg, matches)
    --vardump(msg)
    if matches[1] == 'creagruppo' and matches[2] then
        group_name = matches[2]
        return create_group(msg)
    end

if matches[1] == 'log' and is_owner(msg) then
savelog(msg.to.id, "log creato dal proprietario")
send_document("chat#id"..msg.to.id,"./groups/"..msg.to.id.."log.txt", ok_cb, false)
end


	if matches[1] == 'membrifile' and is_momod(msg) then
local name = user_print_name(msg.from)
savelog(msg.to.id, name.." ["..msg.from.id.."] ha richiesto la lista dei membri ")
local receiver = get_receiver(msg)
chat_info(receiver, returnidsfile, {receiver=receiver})
	end
if matches[1] == 'membrifile' and is_momod(msg) then
local name = user_print_name(msg.from)
savelog(msg.to.id, name.." ["..msg.from.id.."] ha richiesto la lista dei membri come file")
local receiver = get_receiver(msg)
chat_info(receiver, returnids, {receiver=receiver})
	end


    if not is_realm(msg) then
		return
	end
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	if matches[2] then if data[tostring(matches[2])] then
		local settings = data[tostring(matches[2])]['settings']
		if matches[1] == 'impostabout' and matches[2] then
			local target = matches[2]
		    local about = matches[3]
		    return set_description(msg, data, target, about)
		end
		if matches[1] == 'impostaregole' then
		    rules = matches[3]
			local target = matches[2]
		    return set_rules(msg, data, target)
		end
		if matches[1] == 'blocca' then --group lock *
			local target = matches[2]
		    if matches[3] == 'nome' then
		        return lock_group_name(msg, data, target)
		    end
		    if matches[3] == 'membri' then
		        return lock_group_member(msg, data, target)
		    end
		    if matches[3] == 'foto' then
		        return lock_group_photo(msg, data, target)
		    end
		    if matches[3] == 'flood' then
		        return lock_group_flood(msg, data, target)
		    end
		end
		if matches[1] == 'sblocca' then --group unlock *
			local target = matches[2]
		    if matches[3] == 'nome' then
		        return unlock_group_name(msg, data, target)
		    end
		    if matches[3] == 'membri' then
		        return unlock_group_member(msg, data, target)
		    end
		    if matches[3] == 'foto' then
		    	return unlock_group_photo(msg, data, target)
		    end
		    if matches[3] == 'flood' then
		        return unlock_group_flood(msg, data, target)
		    end
		end
		if matches[1] == 'impostazioni' and data[tostring(matches[2])]['settings'] then
			local target = matches[2]
		    return show_group_settings(msg, data, target)
		end
		if matches[1] == 'nome' and is_admin(msg) then
		    local new_name = string.gsub(matches[3], '_', ' ')
		    data[tostring(matches[2])]['settings']['set_name'] = new_name
		    save_data(_config.moderation.data, data)
		    local group_name_set = data[tostring(matches[2])]['settings']['set_name']
		    local to_rename = 'chat#id'..matches[2]
		    rename_chat(to_rename, group_name_set, ok_cb, false)
		end

	end end
		if matches[1] == 'chat_add_user' then
		    if not msg.service then
		        return "Are you trying to troll me?"
		    end
		    local user = 'user#id'..msg.action.user.id
		    local chat = 'chat#id'..msg.to.id
		    if not is_admin(msg) then
				chat_del_user(chat, user, ok_cb, true)
			end
		end
		if matches[1] == 'aggadmin' then
			if string.match(matches[2], '^%d+$') then
				local admin_id = matches[2]
				print("L'utente "..admin_id.." è stato promosso ad amministratore")
				return admin_promote(msg, admin_id)
			else
			local member = string.gsub(matches[2], "@", "")
				local mod_cmd = "aggadmin"
				chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
			end
		end
		if matches[1] == 'rimadmin' then
			if string.match(matches[2], '^%d+$') then
				local admin_id = matches[2]
				print("L'utente "..admin_id.." ora non è più amministratore")
				return admin_demote(msg, admin_id)
			else
			local member = string.gsub(matches[2], "@", "")
				local mod_cmd = "rimadmin"
				chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
			end
		end
		if matches[1] == 'lista' and matches[2] == 'admin' then
			return admin_list(msg)
		end
		if matches[1] == 'lista' and matches[2] == 'gruppi' then
			group_list(msg)
		 send_document("chat#id"..msg.to.id, "groups.txt", ok_cb, false)	
			return "Lista dei gruppi creata" --group_list(msg)
		end
end
 
return {
  patterns = {
    "^/(creagruppo) (.*)$",
    "^/(impostabout) (%d+) (.*)$",
    "^/(impostaregole) (%d+) (.*)$",
    "^/(nome) (%d+) (.*)$",
        "^/(blocca) (%d+) (.*)$",
    "^/(sblocca) (%d+) (.*)$",
    "^/(impostazioni) (%d+)$",
        "^/(membri)$",
        "^/(membrifile)$",
    "^/(aggadmin) (.*)$", -- sudoers only
    "^/(rimadmin) (.*)$", -- sudoers only
    "^/(lista) (.*)$",
        "^/(log)$",
        "^!!tgservice (.+)$",
  },
  run = run
}
end
