local skynet = require "skynet"
local tableutil = require "tableutil"


local M = {}

function M.debug(...)
    skynet.error("\x1b[32m[DEBUG]\x1b[0m", ...)
end

function M.trace(...)
    skynet.error("\x1b[32m[TRACE]\x1b[0m", ...)
end

function M.waring(...)
    skynet.error("\x1b[33m[WARING]\x1b[0m", ...)
end

function M.error(...)
    skynet.error("\x1b[31m[ERROR]\x1b[0m", ...)
    skynet.error("\x1b[31m", debug.traceback(), "\x1b[0m")
end

function M.fatal(...)
    skynet.error("\x1b[31m[FATAL]\x1b[0m", ...)
end

function M.dump(pre, t)
    skynet.error(string.format("\x1b[32m[DUMP]:%s\x1b[0m", pre), tableutil.serialize(t))
end

return M
