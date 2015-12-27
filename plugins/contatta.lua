
local function contatta (testo, utente)
    for v,user in pairs(_config.contatta) do
        receiver = 'user#'..user
    end
    send_msg(receiver, 'ID dell\'utente: '..utente, ok_cb, false)
    send_msg(receiver, 'Testo del messaggio:\n'..testo, ok_cb, false)
end

local function rispondi(id, risp)
    receiver = 'user#'..id
    send_msg(receiver, '-dal proprietario-\n\n'..risp, ok_cb, false)
end



local function run(msg, matches)

if msg.to.type == 'chat' then
  return 'No, in privato'
else
  if matches[1] == 'contatta' then
    contatta (matches[2], msg.from.id)
    return 'Inviato'
    
  elseif matches[1] == 'rispondi' and is_sudo(msg) then
    rispondi(matches[2], matches[3])
    
  end
end
end
  


return {
  patterns = {
    "^/(contatta) (.+)",
    "^/(rispondi) (.+) (.+)"
  }, 
  run = run 
}