local skynet = require "skynet"
local inspect = require "inspect"


local M = {}
M.LEVEL_DEBUG = 1
M.LEVEL_TRACE = 2
M.LEVEL_INFO = 3
M.LEVEL_WARING = 4
M.LEVEL_ERROR = 5
M.LEVEL_FATAL = 6

local _LEVEL = 0
local _ERROR_TRACEBACK = true

local function color_str(color, ...)
    local t = {color, level}
    local args = table.pack(...)
    for i, v in ipairs(args) do
        if type(v) == "table" then
            table.insert(t, inspect(v))
        else
            table.insert(t, tostring(v))
        end
    end
    table.insert(t, "\x1b[0m")
    return table.concat(t, " ")
end

function M.debug(...)
    if _LEVEL > M.LEVEL_DEBUG then
        return
    end
    skynet.error(color_str("\x1b[32m[DEBUG]", ...))
end

function M.trace(...)
    if _LEVEL > M.LEVEL_TRACE then
        return
    end
    skynet.error(color_str("\x1b[32m[TRACE]", ...))
end

function M.info(...)
    if _LEVEL > M.LEVEL_INFO then
        return
    end
    skynet.error(color_str("\x1b[32m[INFO]", ...))
end

function M.warning(...)
    if _LEVEL > M.LEVEL_WARING then
        return
    end
    skynet.error(color_str("\x1b[33m[WARING]", ...))
end

function M.error(...)
    if _LEVEL > M.LEVEL_ERROR then
        return
    end
    local traceback
    local t = table.pack(...)
    if _ERROR_TRACEBACK then
        traceback = debug.traceback()
        table.insert(t, traceback)
    end

    skynet.error(color_str("\x1b[31m[ERROR]", table.unpack(t)))
end

function M.fatal(...)
    if _LEVEL > M.LEVEL_FATAL then
        return
    end
    skynet.error(color_str("\x1b[31m[FATAL]", ...))
end

function M.set_level(level)
    _LEVEL = level or 0
end

function M.is_logger(level)
    return _LEVEL <= level
end

M.set_level(M.LEVEL_DEBUG)

return M
