do
data = load_data(_config.moderation.data)
local function get_msgs_user_chat(user_id, chat_id)
  local user_info = {}
  local uhash = 'user:'..user_id
  local user = redis:hgetall(uhash)
  local um_hash = 'msgs:'..user_id..':'..chat_id
  user_info.msgs = tonumber(redis:get(um_hash) or 0)
  user_info.name = user_print_name(user)..' ['..user_id..']'
  return user_info
end

local function chat_stats(chat_id)
  local hash = 'chat:'..chat_id..':users'
  local users = redis:smembers(hash)
  local users_info = {}
  for i = 1, #users do
    local user_id = users[i]
    local user_info = get_msgs_user_chat(user_id, chat_id)
    table.insert(users_info, user_info)
  end
  table.sort(users_info, function(a, b) 
      if a.msgs and b.msgs then
        return a.msgs > b.msgs
      end
    end)
  local text = 'Statistiche del gruppo:\n'
  for k,user in pairs(users_info) do
    text = text..user.name..' = '..user.msgs..'\n'
  end
  return text
end

local function show_group_settings(target)
  local data = load_data(_config.moderation.data)
  if data[tostring(target)] then
    if data[tostring(target)]['settings']['flood_msg_max'] then
      NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
      print('custom'..NUM_MSG_MAX)
    else 
      NUM_MSG_MAX = 5
    end
  end
  local settings = data[tostring(target)]['settings']
  local text = "Blocco nome: "..settings.lock_name.."\nBlocco foto: "..settings.lock_photo.."\nBlocco membri: "..settings.lock_member.."\nSensitività flood: "..NUM_MSG_MAX
  return text
end

local function get_description(target)
  local data = load_data(_config.moderation.data)
  local data_cat = 'description'
  if not data[tostring(target)][data_cat] then
    return 'Nessuna descrizione disponibile.'
  end
  local about = data[tostring(target)][data_cat]
  return about
end

local function get_rules(target)
  local data = load_data(_config.moderation.data)
  local data_cat = 'rules'
  if not data[tostring(target)][data_cat] then
    return 'Nessuna regola disponibile.'
  end
  local rules = data[tostring(target)][data_cat]
  return rules
end

local function modlist(target)
  local data = load_data(_config.moderation.data)
  if not data[tostring(target)] then
    return 'Il gruppo non è stato aggiunto al mio database.'
  end
  if next(data[tostring(target)]['moderators']) == nil then
    return 'Nessun moderatore in questo gruppo.'
  end
  local i = 1
  local message = '\nLista dei moderatori:\n'
  for k,v in pairs(data[tostring(target)]['moderators']) do
    message = message ..i..' - @'..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

local function get_link(target)
  local data = load_data(_config.moderation.data)
  local group_link = data[tostring(target)]['settings']['set_link']
  if not group_link then 
    return "Nessun link"
  end
  return "link del gruppo:\n"..group_link
end

local function all(target, receiver)
  local text = "Tutto ciò che so su questo gruppo\n \n"
  local settings = show_group_settings(target)
  text = text.."Impostazioni\n"..settings
  local rules = get_rules(target)
  text = text.."\n\nRegole: \n"..rules
  local description = get_description(target)
  text = text.."\n\nDescrizione: \n"..description
  local modlist = modlist(target)
  text = text.."\n\n"..modlist
  local link = get_link(target)
  text = text.."\n\n"..link
  local stats = chat_stats(target)
  text = text.."\n\n"..stats
  local ban_list = ban_list(target)
  text = text.."\n\n"..ban_list
  local file = io.open("./groups/"..target.."all.txt", "w")
  file:write(text)
  file:flush()
  file:close()
  send_document(receiver,"./groups/"..target.."all.txt", ok_cb, false)
  return
end

function run(msg, matches)

  if matches[1] == "tutto" and matches[2] and is_owner2(msg.from.id, matches[2]) then
    local receiver = get_receiver(msg)
    local target = matches[2]
    return all(target, receiver)
  end
  if not is_owner(msg) then
    return 'Non sei il proprietario del gruppo'
  end
  if matches[1] == "tutto" and not matches[2] and msg.to.id ~= our_id then
    local receiver = get_receiver(msg)
    if not is_owner(msg) then
      return 'Non sei il proprietario del gruppo'
    end
    return all(msg.to.id, receiver)
  end

  return
end

return {
  patterns = {
  "^/(tutto)$",
  "^/(tutto) (%d+)$"
  },
  run = run
}
end
