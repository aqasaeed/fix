do

-- Returns the key (index) in the config.enabled_plugins table
local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  -- If not found
  return false
end

-- Returns true if file exists in plugins folder
local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

local function list_plugins(only_enabled)
  local text = ''
  for k, v in pairs( plugins_names( )) do
    --  ✔ enabled, ❌ disabled
    local status = '❌'
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '✔' 
      end
    end
    if not only_enabled or status == '✔' then
      -- get the name
      v = string.match (v, "(.*)%.lua")
      text = text..v..'  '..status..'\n'
    end
  end
  return text
end

local function reload_plugins( )
  plugins = {}
  load_plugins()
  return list_plugins(true)
end


local function enable_plugin( plugin_name )
  print('checking if '..plugin_name..' exists')
  -- Check if plugin is enabled
  if plugin_enabled(plugin_name) then
    return plugin_name..' abilitato'
  end
  -- Checks if plugin exists
  if plugin_exists(plugin_name) then
    -- Add to the config table
    table.insert(_config.enabled_plugins, plugin_name)
    print(plugin_name..' added to _config table')
    save_config()
    -- Reload the plugins
    return reload_plugins( )
  else
    return 'il plugin '..plugin_name..' non esiste'
  end
end

local function disable_plugin( name, chat )
  -- Check if plugins exists
  if not plugin_exists(name) then
    return 'Il plugin '..name..' non esiste'
  end
  local k = plugin_enabled(name)
  -- Check if plugin is enabled
  if not k then
    return 'Il plugin '..name..' non è abilitato'
  end
  -- Disable and reload
  table.remove(_config.enabled_plugins, k)
  save_config( )
  return reload_plugins(true)    
end


local function run(msg, matches)
  -- Show the available plugins 
  if matches[1] == '/plugs' then
    return list_plugins()
  end

  -- Enable a plugin
  if matches[1] == 'a' then
    local plugin_name = matches[2]
    print("enable: "..matches[2])
    return enable_plugin(plugin_name)
  end

  -- Disable a plugin
  if matches[1] == 'd' then
    print("disable: "..matches[2])
    return disable_plugin(matches[2])
  end

  -- Reload all the plugins!
  if matches[1] == 'icarica' then
    return reload_plugins(true)
  end
end

return {
  patterns = {
    "^/plugs",
    "^/p(a) ([%w_%.%-]+)$",
    "^/p(d) ([%w_%.%-]+)$",
    "^/r(icarica)$" },
  run = run,
  privileged = true
}

end