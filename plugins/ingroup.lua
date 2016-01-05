do

local function check_member(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.id
    if member_id ~= our_id then
      -- Group configuration
      data[tostring(msg.to.id)] = {
        moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.print_name, '_', ' '),
          lock_name = 'yes',
          lock_photo = 'no',
          lock_member = 'no',
          lock_bots = 'no',
          lock_arabic = 'no',
          flood = 'yes'
        },
        realm_field = 'no'
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'Ora sei il proprietario del gruppo.')
    end
  end
end

local function check_member_modadd(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.id
    if member_id ~= our_id then
      -- Group configuration
      data[tostring(msg.to.id)] = {
        moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.print_name, '_', ' '),
          lock_name = 'yes',
          lock_photo = 'no',
          lock_member = 'no',
          lock_bots = 'no',
          lock_arabic = 'no',
          flood = 'yes'
        },
        realm_field = 'no'
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'Gruppo indicizzato, ora sei il suo proprietario')
    end
  end
end

local function automodadd(msg)
  local data = load_data(_config.moderation.data)
  if msg.action.type == 'chat_created' then
    receiver = get_receiver(msg)
    chat_info(receiver, check_member,{receiver=receiver, data=data, msg = msg})
  end
end

local function check_member_modrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.id
    if member_id ~= our_id then
      -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'Gruppo rimosso dall\'indice')
    end
  end
end

local function show_group_settingsmod(msg, data, target)
 	if not is_momod(msg) then
    	return "Solo per moderatori!"
  	end
  	local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
     	if data[tostring(msg.to.id)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(msg.to.id)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else 
        	NUM_MSG_MAX = 5
      	end
    end
    local bots_protection = "Yes"
    if data[tostring(msg.to.id)]['settings']['lock_bots'] then
    	bots_protection = data[tostring(msg.to.id)]['settings']['lock_bots']
   	end
  local settings = data[tostring(target)]['settings']
  local text = "Impostazioni gruppo:\nBlocco nome: "..settings.lock_name.."\nBlocco foto: "..settings.lock_photo.."\nBlocco membri: "..settings.lock_member.."\nSensitività flood: "..NUM_MSG_MAX.."\nScudo bot: "..bots_protection
  return text
end

local function set_descriptionmod(msg, data, target, about)
  if not is_momod(msg) then
    return "Solo per moderatori!"
  end
  local data_cat = 'description'
  data[tostring(target)][data_cat] = about
  save_data(_config.moderation.data, data)
  return 'Descrizione del gruppo impostata:\n'..about
end

local function get_description(msg, data)
  local data_cat = 'description'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'Nessuna descrizione disponibile.'
  end
  local about = data[tostring(msg.to.id)][data_cat]
  local about = string.gsub(msg.to.print_name, "_", " ")..':\n\n'..about
  return 'Descrizione '..about
end

local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
    return 'Caratteri arabi già bloccati'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Caratteri arabi bloccati'
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
    return 'Caratteri arabi già sbloccati'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Caratteri arabi sbloccati'
  end
end

local function lock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'yes' then
    return 'Protezione dai bot (API) già abilitata'
  else
    data[tostring(target)]['settings']['lock_bots'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Protezione dai bot (API) abilitata'
  end
end

local function unlock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'no' then
    return 'Protezione dai bot (API) già disabilitata'
  else
    data[tostring(target)]['settings']['lock_bots'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Protezione dai bot (API) disabilitata'
  end
end

local function lock_group_namemod(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
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

local function unlock_group_namemod(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
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

local function lock_group_floodmod(msg, data, target)
  if not is_owner(msg) then
    return "Solo il proprietario può modificare questa impostazione"
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

local function unlock_group_floodmod(msg, data, target)
  if not is_owner(msg) then
    return "Solo il proprietario può modificare questa impostazione"
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

local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
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

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
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

local function unlock_group_photomod(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
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

local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return "Solo per moderatori!"
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'Regole impostate:\n'..rules
end

local function modadd(msg)
  -- superuser and admins only (because sudo are always has privilege)
  if not is_admin(msg) then
    return "Non sei un amministratore"
  end
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    return 'Il gruppo è già aggiunto.'
  end
    receiver = get_receiver(msg)
    chat_info(receiver, check_member_modadd,{receiver=receiver, data=data, msg = msg})
end

local function modrem(msg)
  -- superuser and admins only (because sudo are always has privilege)
  if not is_admin(msg) then
    return "Non sei amministratore"
  end
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
    return 'Il gruppo non era aggiunto.'
  end
    receiver = get_receiver(msg)
    chat_info(receiver, check_member_modrem,{receiver=receiver, data=data, msg = msg})
end

local function realmadd(msg)
  local data = load_data(_config.moderation.data)
  local target = msg.to.id
  local realm_field = data[tostring(target)]['realm_field']
  if realm_field == 'yes' then
    return 'Questo gruppo è già un Realm'
  else
    data[tostring(target)]['realm_field'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'Questo gruppo ora è un Realm'
  end
end

local function realmrem(msg)
  local data = load_data(_config.moderation.data)
  local target = msg.to.id
  local realm_field = data[tostring(target)]['realm_field']
  if realm_field == 'no' then
    return 'Questo gruppo non è un Realm'
  else
    data[tostring(target)]['realm_field'] = 'no'
    save_data(_config.moderation.data, data)
    return 'Questo gruppo ora non è più un Realm'
  end
end

local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'Nessuna regola disponibile.'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local rules = 'Regole:\n'..rules
  return rules
end

local function set_group_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/chat_photo_'..msg.to.id..'.jpg'
    print('File scaricato in:', result)
    os.rename(result, file)
    print('File spostato in:', file)
    chat_set_photo (receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    data[tostring(msg.to.id)]['settings']['lock_photo'] = 'yes'
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Foto salvata!', ok_cb, false)
  else
    print('Errore nel download: '..msg.id)
    send_large_msg(receiver, 'Errore, per favore prova di nuovo!', ok_cb, false)
  end
end

local function promote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Il gruppo non è aggiunto.')
  end
  if data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' è già moderatore.')
  end
  data[group]['moderators'][tostring(member_id)] = member_username
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' è stato promosso moderatore.')
end

local function promote_by_reply(extra, success, result)
    local msg = result
    local full_name = (msg.from.first_name or '')..' '..(msg.from.last_name or '')
    if msg.from.username then
      member_username = '@'..msg.from.username
    else
      member_username = full_name
    end
    local member_id = msg.from.id
    if msg.to.type == 'chat' then
      return promote(get_receiver(msg), member_username, member_id)
    end  
end

local function demote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Il gruppo non è aggiunto.')
  end
  if not data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' non è un moderatore.')
  end
  data[group]['moderators'][tostring(member_id)] = nil
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' ora non è più moderatore.')
end

local function demote_by_reply(extra, success, result)
    local msg = result
    local full_name = (msg.from.first_name or '')..' '..(msg.from.last_name or '')
    if msg.from.username then
      member_username = '@'..msg.from.username
    else
      member_username = full_name
    end
    local member_id = msg.from.id
    if msg.to.type == 'chat' then
      return demote(get_receiver(msg), member_username, member_id)
    end  
end

local function setowner_by_reply(extra, success, result)
  local msg = result
  local receiver = get_receiver(msg)
  local data = load_data(_config.moderation.data)
  local name_log = msg.from.print_name:gsub("_", " ")
  data[tostring(msg.to.id)]['set_owner'] = tostring(msg.from.id)
      save_data(_config.moderation.data, data)
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha impostato ["..msg.from.id.."] come proprietario")
      local text = msg.from.print_name:gsub("_", " ").." è il proprietario"
      return send_large_msg(receiver, text)
end

local function username_id(cb_extra, success, result)
  local mod_cmd = cb_extra.mod_cmd
  local receiver = cb_extra.receiver
  local member = cb_extra.member
  local text = 'Nessun @'..member..' in questo gruppo.'
  for k,v in pairs(result.members) do
    vusername = v.username
    if vusername == member then
      member_username = '@'..member
      member_id = v.id
      if mod_cmd == 'promote' then
        return promote(receiver, member_username, member_id)
      elseif mod_cmd == 'demote' then
        return demote(receiver, member_username, member_id)
      end
    end
  end
  send_large_msg(receiver, text)
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
    return 'Il gruppo non è aggiunto.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then --fix way
    return 'Nessun moderatore in questo gruppo.'
  end
  local i = 1
  local message = '\nLista dei moderatori di ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

local function callbackres(extra, success, result)
  local user = result.id
  local name = string.gsub(result.print_name, "_", " ")
  local chat = 'chat#id'..extra.chatid
  send_large_msg(chat, user..'\n'..name)
  return user
end

local function cleanmember(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name
  if success == -1 then
    return send_large_msg(receiver, '*Errore: nessun link creato* \nNon sono il creatore del gruppo. Solo il creatore può generare un link.')
  end
  for k,v in pairs(result.members) do
    kick_user(v.id, result.id)     
  end
end

local function kicknouser(cb_extra, success, result)
    local chat = "chat#id"..cb_extra.chat
    local user
    for k,v in pairs(result.members) do
        if not v.username then
          user = 'user#id'..v.id
			    chat_del_user(chat, user, ok_cb, true)
		    end
    end
end


local function run(msg, matches)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
   local name_log = user_print_name(msg.from)
  local group = msg.to.id
  if msg.media then
    if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_chat_msg(msg) and is_momod(msg) then
      load_photo(msg.id, set_group_photo, msg)
    end
  end
  if matches[1] == 'agg' then
    print("Gruppo "..msg.to.print_name.."("..msg.to.id..") aggiunto")
    return modadd(msg)
  end
  if matches[1] == 'rim' then
    print("Gruppo "..msg.to.print_name.."("..msg.to.id..") rimosso")
    return modrem(msg)
  end
  if matches[1] == 'chat_created' and msg.from.id == 0 then
    return automodadd(msg)
  end
  if msg.to.id and data[tostring(msg.to.id)] then
    local settings = data[tostring(msg.to.id)]['settings']
    if matches[1] == 'chat_add_user' then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local group_member_lock = settings.lock_member
      local user = 'user#id'..msg.action.user.id
      local chat = 'chat#id'..msg.to.id
      if group_member_lock == 'yes' and not is_owner2(msg.action.user.id, msg.to.id) then
        chat_del_user(chat, user, ok_cb, true)
      elseif group_member_lock == 'yes' and tonumber(msg.from.id) == tonumber(our_id) then
        return nil
      elseif group_member_lock == 'no' then
        return nil
      end
    end
    if matches[1] == 'chat_add_user' then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local receiver = 'user#id'..msg.action.user.id
      local data_cat = 'rules'
      if not data[tostring(msg.to.id)][data_cat] then
        return false
      end
      local rules = data[tostring(msg.to.id)][data_cat]
      local rules = 'Benvenuto in "' .. string.gsub(msg.to.print_name, '_', ' ') ..'", ecco le regole del gruppo:\n'..rules
      
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha rimosso  "..msg.action.user.id)
      send_large_msg(receiver, rules)
    end
    if matches[1] == 'chat_del_user' then
      if not msg.service then
          return "Are you trying to troll me?"
      end
      local user = 'user#id'..msg.action.user.id
      local chat = 'chat#id'..msg.to.id
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted user  "..user)
    end
    if matches[1] == 'chat_delete_photo' then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local group_photo_lock = settings.lock_photo
      if group_photo_lock == 'yes' then
        local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
        redis:incr(picturehash)
        ---
        local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
        local picprotectionredis = redis:get(picturehash) 
        if picprotectionredis then 
          if tonumber(picprotectionredis) == 4 and not is_owner(msg) then 
            kick_user(msg.from.id, msg.to.id)
          end
          if tonumber(picprotectionredis) ==  8 and not is_owner(msg) then 
            ban_user(msg.from.id, msg.to.id)
            local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
            redis:set(picturehash, 0)
          end
        end
        
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha provato a rimuovere la foto ma ha fallito ")
        chat_set_photo(receiver, settings.set_photo, ok_cb, false)
      elseif group_photo_lock == 'no' then
        return nil
      end
    end
    if matches[1] == 'chat_change_photo' and msg.from.id ~= 0 then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local group_photo_lock = settings.lock_photo
      if group_photo_lock == 'yes' then
        local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
        redis:incr(picturehash)
        ---
        local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
        local picprotectionredis = redis:get(picturehash) 
        if picprotectionredis then 
          if tonumber(picprotectionredis) == 4 and not is_owner(msg) then 
            kick_user(msg.from.id, msg.to.id)
          end
          if tonumber(picprotectionredis) ==  8 and not is_owner(msg) then 
            ban_user(msg.from.id, msg.to.id)
          local picturehash = 'picture:changed:'..msg.to.id..':'..msg.from.id
          redis:set(picturehash, 0)
          end
        end
        
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha provato a cambiare la foto ma ha fallito ")
        chat_set_photo(receiver, settings.set_photo, ok_cb, false)
      elseif group_photo_lock == 'no' then
        return nil
      end
    end
    if matches[1] == 'chat_rename' then
      if not msg.service then
        return "Are you trying to troll me?"
      end
      local group_name_set = settings.set_name
      local group_name_lock = settings.lock_name
      local to_rename = 'chat#id'..msg.to.id
      if group_name_lock == 'yes' then
        if group_name_set ~= tostring(msg.to.print_name) then
          local namehash = 'name:changed:'..msg.to.id..':'..msg.from.id
          redis:incr(namehash)
          local namehash = 'name:changed:'..msg.to.id..':'..msg.from.id
          local nameprotectionredis = redis:get(namehash) 
          if nameprotectionredis then 
            if tonumber(nameprotectionredis) == 4 and not is_owner(msg) then 
              kick_user(msg.from.id, msg.to.id)
            end
            if tonumber(nameprotectionredis) ==  8 and not is_owner(msg) then 
              ban_user(msg.from.id, msg.to.id)
              local namehash = 'name:changed:'..msg.to.id..':'..msg.from.id
              redis:set(namehash, 0)
            end
          end
          
          savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha provato a cambiare il nome ma ha fallito ")
          rename_chat(to_rename, group_name_set, ok_cb, false)
        end
      elseif group_name_lock == 'no' then
        return nil
      end
    end
    if matches[1] == 'nome' and is_momod(msg) then
      local new_name = string.gsub(matches[2], '_', ' ')
      data[tostring(msg.to.id)]['settings']['set_name'] = new_name
      save_data(_config.moderation.data, data)
      local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
      local to_rename = 'chat#id'..msg.to.id
      rename_chat(to_rename, group_name_set, ok_cb, false)
      
      savelog(msg.to.id, "Gruppo { "..msg.to.print_name.." }  nome cambiato in [ "..new_name.." ] da "..name_log.." ["..msg.from.id.."]")
    end
    if matches[1] == 'foto' and is_momod(msg) then
      data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
      save_data(_config.moderation.data, data)
      return 'Per favore inviami la nuova foto del gruppo ora'
    end
    if matches[1] == 'promuovi' and not matches[2] then
      if not is_owner(msg) then
        return "Solo il proprietario può promuovere nuovi moderatori"
      end
      if type(msg.reply_id)~="nil" then
          msgr = get_message(msg.reply_id, promote_by_reply, false)
      end
    end
    if matches[1] == 'promuovi' and matches[2] then
      if not is_owner(msg) then
        return "Solo il proprietario può promuovere nuovi moderatori"
      end
      local member = string.gsub(matches[2], "@", "")
      local mod_cmd = 'promote' 
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha promosso @".. member)
      chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
    end
    if matches[1] == 'degrada' and not matches[2] then
      if not is_owner(msg) then
        return "Solo il proprietario può degradare un moderatore"
      end
      if type(msg.reply_id)~="nil" then
          msgr = get_message(msg.reply_id, demote_by_reply, false)
      end
    end
    if matches[1] == 'degrada' and matches[2] then
      if not is_owner(msg) then
        return "Solo il proprietario può degradare un moderatore"
      end
      if string.gsub(matches[2], "@", "") == msg.from.username then
        return "Non puoi rinunciare alla carica di moderatore da solo"
      end
      local member = string.gsub(matches[2], "@", "")
      local mod_cmd = 'demote'
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha degradato @".. member)
      chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
    end
    if matches[1] == 'listamod' then
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha richiesto la lista dei moderatori")
      return modlist(msg)
    end
    if matches[1] == 'about' then
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha richiesto la descrizione")
      return get_description(msg, data)
    end
    if matches[1] == 'regole' then
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha richiesto le regole")
      return get_rules(msg, data)
    end
    if matches[1] == 'setta' then
      if matches[2] == 'regole' then
        rules = matches[3]
        local target = msg.to.id
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha cambiato le regole in ["..matches[3].."]")
        return set_rulesmod(msg, data, target)
      end
      if matches[2] == 'about' then
        local data = load_data(_config.moderation.data)
        local target = msg.to.id
        local about = matches[3]
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha cambiato la descrizione in ["..matches[3].."]")
        return set_descriptionmod(msg, data, target, about)
      end
    end
    if matches[1] == 'blocca' then
      local target = msg.to.id
      if matches[2] == 'nome' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha bloccato il nome ")
        return lock_group_namemod(msg, data, target)
      end
      if matches[2] == 'membri' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha bloccato i membri ")
        return lock_group_membermod(msg, data, target)
        end
      if matches[2] == 'flood' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha bloccato il flood ")
        return lock_group_floodmod(msg, data, target)
      end
      if matches[2] == 'arabo' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha bloccato i caratteri arabi ")
        return lock_group_arabic(msg, data, target)
      end
      if matches[2] == 'bot' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha bloccato i bot ")
        return lock_group_bots(msg, data, target)
      end
    end
    if matches[1] == 'sblocca' then 
      local target = msg.to.id
      if matches[2] == 'nome' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha sbloccato il nome ")
        return unlock_group_namemod(msg, data, target)
      end
      if matches[2] == 'membri' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha sbloccato i membri ")
        return unlock_group_membermod(msg, data, target)
      end
      if matches[2] == 'foto' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha sbloccato la foto ")
        return unlock_group_photomod(msg, data, target)
      end
      if matches[2] == 'flood' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha sbloccato il flood ")
        return unlock_group_floodmod(msg, data, target)
      end
      if matches[2] == 'arabo' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha sbloccato la lingua araba ")
        return unlock_group_arabic(msg, data, target)
      end
      if matches[2] == 'bot' then
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha sbloccato i bot ")
        return unlock_group_bots(msg, data, target)
      end
    end
    if matches[1] == 'info' then
      local target = msg.to.id
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha richiesto le impostazioni ")
      return show_group_settingsmod(msg, data, target)
    end
    if matches[1] == 'nuovolink' then
      if not is_momod(msg) then
        return "Solo per moderatori!"
      end
      local function callback (extra , success, result)
        local receiver = 'chat#'..msg.to.id
        if success == 0 then
           return send_large_msg(receiver, '*Errore: link non creato* \nNon sono il creatore di questo gruppo, solo il creatore può generare il link.')
        end
        send_large_msg(receiver, "Nuovo link creato")
        data[tostring(msg.to.id)]['settings']['set_link'] = result
        save_data(_config.moderation.data, data)
      end
      local receiver = 'chat#'..msg.to.id
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha revocato il link ")
      return export_chat_link(receiver, callback, true)
    end
    if matches[1] == 'link' then
      if not is_momod(msg) then
        return "Solo per moderatori!"
      end
      local group_link = data[tostring(msg.to.id)]['settings']['set_link']
      if not group_link then 
        return "Crea un nuovo link usando /nuovolink prima!"
      end
       savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha richiesto il link ["..group_link.."]")
      return "Link del gruppo:\n"..group_link
    end
    if matches[1] == 'setboss' and matches[2] then
      if not is_owner(msg) then
        return "Solo per il proprietario!"
      end
      data[tostring(msg.to.id)]['set_owner'] = matches[2]
      save_data(_config.moderation.data, data)
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha impostato ["..matches[2].."] come proprietario")
      local text = matches[2].." impostato come proprietario"
      return text
    end
    if matches[1] == 'setboss' and not matches[2] then
      if not is_owner(msg) then
        return "Solo per il proprietario!"
      end
      if type(msg.reply_id)~="nil" then
          msgr = get_message(msg.reply_id, setowner_by_reply, false)
      end
    end
    if matches[1] == 'boss' then
      local group_owner = data[tostring(msg.to.id)]['set_owner']
      if not group_owner then 
        return "Nessun proprietario. Chiedi ad un amministratore del bot di impostare il proprietario di questo gruppo"
      end
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
      return "Il proprietario è ["..group_owner..']'
    end
    if matches[1] == 'setgrboss' then
      local receiver = "chat#id"..matches[2]
      if not is_admin(msg) then
        return "Solo per amministratori!"
      end
      data[tostring(matches[2])]['set_owner'] = matches[3]
      save_data(_config.moderation.data, data)
      local text = matches[3].." impostato come proprietario"
      send_large_msg(receiver, text)
      return
    end
    if matches[1] == 'setflood' then 
      if not is_momod(msg) then
        return "Solo per moderatori!"
      end
      if tonumber(matches[2]) < 5 or tonumber(matches[2]) > 20 then
        return "Il valore deve rientrare nel range [5-20]"
      end
      local flood_max = matches[2]
      data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
      save_data(_config.moderation.data, data)
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha impostato il flood a ["..matches[2].."]")
      return 'Flood impostato a '..matches[2]
    end
    if matches[1] == 'spazza' then
      if not is_owner(msg) then
        return "Solo il proprietario può cancellare"
      end
      if matches[2] == 'membri' then
        if not is_owner(msg) then
          return "Solo il proprietario può eliminare tutti i membri"
        end
        local receiver = get_receiver(msg)
        chat_info(receiver, cleanmember, {receiver=receiver})
      end
      if matches[2] == 'mod' then
        if next(data[tostring(msg.to.id)]['moderators']) == nil then --fix way
          return 'Nessun moderatore in questo gruppo.'
        end
        --local message = '\nLista dei moderatori di ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
        for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
          data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
          save_data(_config.moderation.data, data)
        end
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha rimosso i moderatori")
        return 'Moderatori rimossi'
      end
      if matches[2] == 'regole' then 
        local data_cat = 'rules'
        data[tostring(msg.to.id)][data_cat] = nil
        save_data(_config.moderation.data, data)
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha rimosso le regole")
        return 'Regole rimosse'
      end
      if matches[2] == 'about' then 
        local data_cat = 'description'
        data[tostring(msg.to.id)][data_cat] = nil
        save_data(_config.moderation.data, data)
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha rimosso la descrizione")
        return 'Descrizione rimossa'
      end     
    end 
    if matches[1] == 'res' and is_momod(msg) then 
      local cbres_extra = {
        chatid = msg.to.id
      }
      local username = matches[2]
      local username = username:gsub("@","")
      savelog(msg.to.id, name_log.." ["..msg.from.id.."] ha usato /res "..username)
      return res_user(username,  callbackres, cbres_extra)
    end
    if matches[1] == 'aggrealm' and is_admin(msg) then
      print("Gruppo "..msg.to.print_name.."("..msg.to.id..") aggiunto ai realm")
      return realmadd(msg)
    end
    if matches[1] == 'rimrealm' and is_admin(msg) then
      print("Gruppo "..msg.to.print_name.."("..msg.to.id..") rimosso dai realm")
      return realmrem(msg)
    end
    if matches[1] == 'isrealm' then
      if is_realmM(msg) then
        return 'Questo gruppo è un Realm'
      else
        return 'Questo gruppo non è un Realm'
      end
  end
    if matches[1] == 'kickanouser' then
      if not is_owner(msg) then 
		    return "Solo il proprietario può usare questo comando!"
	    end
	    chat_info(receiver, kicknouser, {chat = msg.to.id})
    end
  end 
end
return {
  patterns = {
  "^/(agg)$",
  "^/(rim)$",
  "^/(regole)$",
  "^/(about)$",
  "^/(nome) (.*)$",
  "^/(foto)$",
  "^/(promuovi) (.*)$",
  "^/(promuovi)",
  "^/(spazza) (.*)$",
  "^/(degrada) (.*)$",
  "^/(degrada)",
  "^/(setta) ([^%s]+) (.*)$",
  "^/(blocca) (.*)$",
  "^/(setboss) (%d+)$",
  "^/(setboss)",
  "^/(boss)$",
  "^/(res) (.*)$",
  "^/(setgrboss) (%d+) (%d+)$",-- (group id) (owner id)
  "^/(sblocca) (.*)$",
  "^/(setflood) (%d+)$",
  "^/(info)$",
  "^/(listamod)$",
  "^/(nuovolink)$",
  "^/(link)$",
  "^/(aggrealm)$",
  "^/(rimrealm)$",
  "^/(isrealm)$",
  "^/(kickanouser)$",
  "%[(photo)%]",
  "^!!tgservice (.+)$",
  },
  run = run
}
end
















