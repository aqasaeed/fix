

local function lock_group_namemod(msg, data, target)
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
  local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
  if group_photo_lock == 'no' then
      return 'Foto già sbloccata'
  else
      data[tostring(target)]['settings']['lock_photo'] = 'no'
      save_data(_config.moderation.data, data)
  return 'Foto sbloccata'
  end
end

local function show_group_settingsmod(msg, data, target)
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
      if data[tostring(msg.to.id)]['settings']['flood_msg_max'] then
        NUM_MSG_MAX = tonumber(data[tostring(msg.to.id)]['settings']['flood_msg_max'])
        print('custom'..NUM_MSG_MAX)
      else 
        NUM_MSG_MAX = 5
      end
    end
    local settings = data[tostring(target)]['settings']
    local text = "Impostazioni gruppo:\nBlocco nome: "..settings.lock_name.."\nBlocco foto: "..settings.lock_photo.."\nBlocco membri: "..settings.lock_member.."\nSensitività flood: "..NUM_MSG_MAX
    return text
end

local function set_rules(target, rules)
  local data = load_data(_config.moderation.data)
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'Regole impostate:\n'..rules
end

local function set_description(target, about)
  local data = load_data(_config.moderation.data)
  local data_cat = 'description'
  data[tostring(target)][data_cat] = about
  save_data(_config.moderation.data, data)
  return 'Descrizione impostata:\n'..about
end

local function run(msg, matches)
  if msg.to.type ~= 'chat' then
    local chat_id = matches[1]
    local receiver = get_receiver(msg)
    local data = load_data(_config.moderation.data)
    if matches[2] == 'banna' then
      local chat_id = matches[1]
      if not is_owner2(msg.from.id, chat_id) then
        return "Non sei il proprietario di questo gruppo"
      end
      if tonumber(matches[3]) == tonumber(our_id) then return false end
      local user_id = matches[3]
      if tonumber(matches[3]) == tonumber(msg.from.id) then 
        return "Non puoi bannarti da solo"
      end
      ban_user(matches[3], matches[1])
      local name = user_print_name(msg.from)
      savelog(matches[1], name.." ["..msg.from.id.."] ha bannato ".. matches[3])
      return 'L\'utente '..user_id..' è stato bannato'
    end
    if matches[2] == 'unbanna' then
    if tonumber(matches[3]) == tonumber(our_id) then return false end
      local chat_id = matches[1]
      if not is_owner2(msg.from.id, chat_id) then
        return "Non sei il proprietario di questo gruppo"
      end
      local user_id = matches[3]
      if tonumber(matches[3]) == tonumber(msg.from.id) then 
        return "Non puoi unbannarti da solo"
      end
      local hash =  'banned:'..matches[1]
      redis:srem(hash, user_id)
      local name = user_print_name(msg.from)
      savelog(matches[1], name.." ["..msg.from.id.."] ha unbannato ".. matches[3])
      return 'L\'utente '..user_id..' è stato unbannato'
    end
    if matches[2] == 'kicka' then
      local chat_id = matches[1]
      if not is_owner2(msg.from.id, chat_id) then
        return "Non sei il proprietario di questo gruppo"
      end
      if tonumber(matches[3]) == tonumber(our_id) then return false end
      local user_id = matches[3]
      if tonumber(matches[3]) == tonumber(msg.from.id) then 
        return "Non puoi kickarti da solo"
      end
      kick_user(matches[3], matches[1])
      local name = user_print_name(msg.from)
      savelog(matches[1], name.." ["..msg.from.id.."] ha kickato ".. matches[3])
      return 'L\'utente '..user_id..' è stato kickato'
    end
    if matches[2] == 'rim' then
      if matches[3] == 'mod' then
        if not is_owner2(msg.from.id, chat_id) then
          return "Non sei il proprietario di questo gruppo"
        end
        for k,v in pairs(data[tostring(matches[1])]['moderators']) do
          data[tostring(matches[1])]['moderators'][tostring(k)] = nil
          save_data(_config.moderation.data, data)
        end
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha rimosso i moderatori")
      end
      if matches[3] == 'regole' then
        if not is_owner2(msg.from.id, chat_id) then
          return "Non sei il proprietario di questo gruppo"
        end
        local data_cat = 'rules'
        data[tostring(matches[1])][data_cat] = nil
        save_data(_config.moderation.data, data)
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha rimosso le regole")
      end
      if matches[3] == 'des' then
        if not is_owner2(msg.from.id, chat_id) then
          return "Non sei il proprietario di questo gruppo"
        end
        local data_cat = 'description'
        data[tostring(matches[1])][data_cat] = nil
        save_data(_config.moderation.data, data)
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha rimosso la descrizione")
      end
    end
    if matches[2] == "imflood" then
      if not is_owner2(msg.from.id, chat_id) then
        return "Non sei il proprietario di questo gruppo"
      end
      if tonumber(matches[3]) < 5 or tonumber(matches[3]) > 20 then
        return "Numero non consentito. Il range è [5-20]"
      end
      local flood_max = matches[3]
      data[tostring(matches[1])]['settings']['flood_msg_max'] = flood_max
      save_data(_config.moderation.data, data)
      local name = user_print_name(msg.from)
      savelog(matches[1], name.." ["..msg.from.id.."] ha impostato il flood a ["..matches[3].."]")
      return 'Flood impostato a '..matches[3]
    end
    if matches[2] == 'blocca' then
      if not is_owner2(msg.from.id, chat_id) then
        return "Non sei il proprietario di questo gruppo"
      end
      local target = matches[1]
      if matches[3] == 'nome' then
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha bloccato il nome ")
        return lock_group_namemod(msg, data, target)
      end
      if matches[3] == 'membri' then
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha bloccato i membri ")
        return lock_group_membermod(msg, data, target)
      end
    end
    if matches[2] == 'sblocca' then
      if not is_owner2(msg.from.id, chat_id) then
        return "Non sei il proprietario di questo gruppo"
      end
      local target = matches[1]
      if matches[3] == 'nome' then
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha sbloccato il nome ")
        return unlock_group_namemod(msg, data, target)
      end
      if matches[3] == 'membri' then
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha sbloccato i membri ")
        return unlock_group_membermod(msg, data, target)
      end
    end
    if matches[2] == 'nuovo' then
      if matches[3] == 'link' then
        if not is_owner2(msg.from.id, chat_id) then
          return "Non sei il proprietario di questo gruppo"
        end
        local function callback (extra , success, result)
          local receiver = 'chat#'..matches[1]
          vardump(result)
          data[tostring(matches[1])]['settings']['set_link'] = result
          save_data(_config.moderation.data, data)
          return 
        end
        local receiver = 'chat#'..matches[1]
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha revocato il link ")
        export_chat_link(receiver, callback, true)
        return "Nuovo link creato! \nDisponibile tramite /owner "..matches[1].." mostra link"
      end
    end
    if matches[2] == 'mostra' then 
      if matches[3] == 'link' then
        if not is_owner2(msg.from.id, chat_id) then
          return "Non sei il proprietario di questo gruppo"
        end
        local group_link = data[tostring(matches[1])]['settings']['set_link']
        if not group_link then 
          return "Crea un link usando /nuovo link prima!"
        end
        local name = user_print_name(msg.from)
        savelog(matches[1], name.." ["..msg.from.id.."] ha richiesto il link ["..group_link.."]")
        return "Link del gruppo:\n"..group_link
      end
    end
    if matches[1] == 'cambiades' and matches[2] and is_owner2(msg.from.id, matches[2]) then
      local target = matches[2]
      local about = matches[3]
      local name = user_print_name(msg.from)
      savelog(matches[2], name.." ["..msg.from.id.."] ha cambiato la descrizione in ["..matches[3].."]")
      return set_description(target, about)
    end
    if matches[1] == 'cambiaregole' and is_owner2(msg.from.id, matches[2]) then
      local rules = matches[3]
      local target = matches[2]
      local name = user_print_name(msg.from)
      savelog(matches[2], name.." ["..msg.from.id.."] ha cambiato le regole in ["..matches[3].."]")
      return set_rules(target, rules)
    end
    if matches[1] == 'cambianome' and is_owner2(msg.from.id, matches[2]) then
      local new_name = string.gsub(matches[3], '_', ' ')
      data[tostring(matches[2])]['settings']['set_name'] = new_name
      save_data(_config.moderation.data, data)
      local group_name_set = data[tostring(matches[2])]['settings']['set_name']
      local to_rename = 'chat#id'..matches[2]
      local name = user_print_name(msg.from)
      savelog(matches[2], "Nome cambiato in [ "..new_name.." ] da "..name.." ["..msg.from.id.."]")
      rename_chat(to_rename, group_name_set, ok_cb, false)
      return 'Nome '..matches[2]..' cambiato in '.. new_name
    end
    if matches[1] == 'loggruppo' and matches[2] and is_owner2(msg.from.id, matches[2]) then
      savelog(matches[2], "------")
      send_document("user#id".. msg.from.id,"./groups/"..matches[2].."log.txt", ok_cb, false)
    end
  end
end
return {
  patterns = {
    "^/owner (%d+) ([^%s]+) (.*)$",
    "^/owner (%d+) ([^%s]+)$",
    "^/(cambiades) (%d+) (.*)$",
    "^/(cambiaregole) (%d+) (.*)$",
    "^/(cambianome) (%d+) (.*)$",
		"^/(loggruppo) (%d+)$"
  },
  run = run
}
