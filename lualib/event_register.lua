-- 事件注册派发器 class 封装
-- auth:diandian
-- date:2018/04/23



return function(M, ud)

local _events = {}

function M:attach(e, fn, m)
    assert(type(e) == "string" and e ~= "", "bad detach argument")
    assert(type(fn) == "function", "bad func argument!")
    local con = _events[e]
    if not con then
        con = {}
        _events[e] = con
    end
    if m then
        assert(type(m) == "table", "bad obj argument!")
        con[m] = fn
    else
        con[fn] = 1
    end
end

function M:detach(e, fn, m)
    assert(type(e) == "string" and e ~= "", "bad detach argument")
    assert(type(fn) == "function", "bad func argument!")
    local con = _events[e]
    if not con then return end
    if obj then
        assert(type(m) == "table", "bad obj argument!")
        con[m] = nil
    else
        con[fn] = nil
    end
end

function M:notify(e, ...)
    assert(e)
    local con = _events[e]
    --DEBUG("event notify:", e, con, ...)
    if not con then return end
    for k, v in pairs(con) do
        if type(k) == "table" then
            v(k, ud, e, ...)
        elseif type(k) == "function" then
            k(ud, e, ...)
        else
            assert(false, type(k))
        end
    end
end

return M
end