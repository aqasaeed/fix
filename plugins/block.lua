local function run(msg, matches)
    if not is_admin(msg) then
        return
    end
    if matches[1] == "block" then
	    local user_id = "user#id"..matches[2]
	    block_user(user_id, ok_cb, false)
    end
    if matches[1] == "sblock" then
	    local user_id = "user#id"..matches[2]
	    unblock_user(user_id, ok_cb, false)
    end
end

return {
  patterns = {
    "^/(block) (.*)$",
    "^/(sblock) (.*)$"
  },
  run = run
}