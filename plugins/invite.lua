do
local function callbackres(extra, success, result) -- Callback for res_user in line 27
  local user = 'user#id'..result.id
	local chat = 'chat#id'..extra.chatid
	if is_banned(result.id, extra.chatid) then -- Ignore bans
      send_large_msg(chat, 'L\'utente è bannato.')
	elseif is_gbanned(result.id) then -- Ignore globall bans
	    send_large_msg(chat, 'L\'utente è bannato globalmente.')
	else    
	    chat_add_user(chat, user, ok_cb, false) -- Add user on chat
	end
end

local function invite_by_reply(extra, success, result)
  local msg = result
  local chat = 'chat#id'..msg.to.id
  local user = 'user#id'..msg.from.id
  if is_banned(msg.from.id, msg.to.id) then -- Ignore bans
      send_large_msg(chat, 'L\'utente è bannato.')
	elseif is_gbanned(msg.from.id) then -- Ignore globall bans
	    send_large_msg(chat, 'L\'utente è bannato globalmente.')
	else    
	    chat_add_user(chat, user, ok_cb, false) -- Add user on chat
	end
end


function run(msg, matches)
  local data = load_data(_config.moderation.data)
  if not is_realm(msg) then
    if data[tostring(msg.to.id)]['settings']['lock_member'] == 'yes' and not is_admin(msg) then
		  return 'Il gruppo in questo momento è privato.'
    end
  end
  if msg.to.type ~= 'chat' then 
    return
  end
  if not is_momod(msg) then
    return 'Solo per moderatori'
  end
  --if not is_admin(msg) then -- For admins only !
    --return 'Only admins can invite.'
  --end
  if matches[1] == 'invita' and not matches[2] then
    if type(msg.reply_id)~="nil" then
        msgr = get_message(msg.reply_id, invite_by_reply, false)
    end
  end
  if matches[1] == 'invita' and matches[2] then
    if string.match(matches[2], '^%d+$') then
      chat_add_user('chat#id'..msg.to.id, 'user#id'..matches[2], ok_cb, false)
    else	  
	    local cbres_extra = {chatid = msg.to.id}
      local username = matches[2]
      local username = username:gsub("@","")
      res_user(username,  callbackres, cbres_extra)
    end
  end
end

return {
    patterns = {
      "^/(invita) (.*)$",
      "^/(invita)"
    },
    run = run
}

end