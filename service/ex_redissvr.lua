local skynet = require 'skynet'
require 'skynet.manager'
local redis = require 'redis'

local _conf
local _db

skynet.start(function (conf)
    _conf = conf
    _db = redis.connect(conf)
    skynet.dispatch("lua", function(_, _, cmd, ...)
        return _db[cmd](_db, cmd, ...)
    end)
end)
