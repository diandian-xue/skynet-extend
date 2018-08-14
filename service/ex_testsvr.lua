local skynet = require "skynet"
require "skynet.manager"

local protobuf = require "protobuf"
local skiplist = require "skiplist"

local CMD = {}

skynet.start(function ()
    local conf = {
        name = "test_websvr",
        host = "0.0.0.0",
        port = 8080,
        agent_num = 10,
        execute = nil,
        domains = {},
    }
    local svr = skynet.newservice("ex_websvr")
    skynet.call(svr, "lua", "start", conf)

    skynet.dispatch("lua", function(session, source, cmd, ...)
        return skynet.retpack(CMD[cmd](...))
    end)
end)
