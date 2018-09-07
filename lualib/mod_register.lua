-- 角色数据逻辑框架封装
-- auth:diandian
-- date:2018/03/28

local skynet = require "skynet"
local ex_log = require "ex_log"

local rawget, rawset, setmetatable = rawget, rawset, setmetatable
local pairs, ipairs, type = pairs, ipairs, type

local mt = {}
mt.__call = function(self, player, top, parent, name)
    local t = {}
    t.player__ = player
    t.name__ = name
    t.mods__ = {}
    t.save_flag_map_ = {}
    t.save_flag_ = false
    t.events__ = {}
    t.parent__ = parent
    t.top__ = top or t

    t.mod_inited__ = {}
    t.mod_inited_co__ = {}
    setmetatable(t, self)
    return t, t:initalize__(player)
end

return function(class)
    local modclass = {}

    function class.register_child(name, class)
        assert(type(class) == "table", name)
        assert(not modclass[name], name)
        modclass[name] = class
    end

    function class:initalize__(player)
        local fn = rawget(class, "init")
        if fn then
            fn(self, player)
        end
        if self.player__.day_changed then
            m:day_change()
        end
    end


    function class:get_child(name)
        local m = self.mods__[name]
        if not m then
            local c = modclass[name]
            assert(c, name)
            if self.mod_inited__[name] then
                local co = coroutine.running()
                table.insert(self.mod_inited_co__, co)
                skynet.wait()
                assert(self.mods__[name], name)
                return self.mods__[name]
            end
            self.mod_inited__[name] = true
            m = c(self.player__, self.top__, self, name)
            assert(m, name)
            self.mods__[name] = m
            for i, v in ipairs(self.mod_inited_co__) do
                skynet.fork(function()
                    skynet.wakeup(v)
                end)
            end
            self.mod_inited_co__ = {}
            self.mod_inited__ = {}
        end
        return m
    end

    function class:get_player()
        return self.player__
    end

    function class:set_player(p)
        self.player__ = p
    end

    function class:get_module(mods)
        local m = self.top__
        for i, v in ipairs(mods) do
            m = m:get_child(v)
            assert(m, v)
        end
        return m
    end

    function class:have_child(name)
        return self.mods__[name]
    end

    function class:have_module(mods)
        local m = self.top__
        for i, v in ipairs(mods) do
            m = m:have_child(v)
            if not m then
                return nil
            end
        end
        return m
    end

    function class:get_parent()
        return self.parent__
    end

    function class:save(flag)
        if flag then
            self.save_flag_map_[flag] = true
        else
            self.save_flag_ = true
        end
    end

    function class:get_fule_name()
        local n = {}
        table.insert(n, self.name__)
        local p = self.parent__
        while p do
            table.insert(n, 1, p.name__)
            p = self.parent__
        end
        return table.concat(n, ".")
    end

    function class:call(mods, f, ...)
        local m = self:get_module(mods)
        assert(m, mods)
        local fn = m[f]
        assert(fn, f)
        return fn(m, ...)
    end

    function class:notify(e, ...)
        local mod_evt = self.player__.mod_evt
        mod_evt:notify(e, ...)
    end

    function class:check_save()
        local fn = rawget(class, "on_save")
        if not fn then
            return
        end
        if self.save_flag_ then
            local ret = xpcall(fn, ex_log.error, self, self.player__)
            if ret then
                self.save_flag_ = false
            else
            end
        end

        if next(self.save_flag_map_) then
            local saved = {}
            for k, _ in pairs(self.save_flag_map_) do
                local ret = xpcall(fn, ex_log.error, self, self.player__, k)
                if ret then
                    table.insert(saved, k)
                end
            end
            for i, v in ipairs(saved) do
                self.save_flag_map_[v] = nil
            end
        end

        for k, v in pairs(self.mods__) do
            v:check_save()
        end
    end

    function class:day_change()
        local fn = rawget(class, "on_day_change")
        if fn then
            xpcall(fn, ex_log.error, self, self.player__)
        end
        for k, v in pairs(self.mods__) do
            v:day_change()
        end
    end

    class.__index = function(self, k)
        return rawget(class, k)
    end
    return setmetatable(class, mt)
end
