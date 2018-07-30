thread    = 2
bootstrap = "snlua bootstrap"

harbor     = 0
logservice = "ex_loggersvr"
daemon     = nil
start      = "ex_testsvr"
profile    = false

if not skynet_extend then
    skynet_extend = ""--"skynet_extend/"
end
local function concat_ddpath(args)
    local r = ''
    for i = 1, # args do
        r = r .. ';' .. skynet_extend .. args[i]
    end
    return r .. ";"
end

lualoader  = skynet_extend .. "skynet/lualib/loader.lua"
cpath = concat_ddpath {
    "skynet/cservice/?.so",
    "cservice/?.so",
    "luaclib/?.so",
}

luaservice = concat_ddpath {
  "skynet/service/?.lua",
  "service/?.lua",
}

lua_path = concat_ddpath {
  "skynet/lualib/?.lua",
  "skynet/lualib/compat10/?.lua",
  "lualib/?.lua",
  "service/?.lua",
}

lua_cpath = concat_ddpath {
  "skynet/luaclib/?.so",
  "luaclib/?.so",
  "cservice/?.so",
}
