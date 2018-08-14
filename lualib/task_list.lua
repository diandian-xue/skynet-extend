-- 任务执行列表管理
-- auth:diandian
-- date:2018/03/15
-- 任务列表封装, 每个执行函数或者时间段为一个任务
-- 组成一个列表, 只有前面一个任务完成才会触发下一个任务开始

local function create_task(end_time, TL)
    local tk = {}

    local time = 0
    end_time = end_time or 0

    local start_fn
    local complete_fn
    local completed = false

    function tk._start()
        if start_fn then
            start_fn()
        end
    end

    function tk._update(dt)
        if end_time <= 0 then
            return
        end
        time = time + dt
        if time >= end_time then
            tk.complete()
        end
    end

    function tk.complete()
        assert(not completed)
        local ret = TL._complete(tk)
        if ret and complete_fn then
            complete_fn()
        end
    end

    function tk.on_start(fn)
        start_fn = fn
    end

    function tk.on_complete(fn)
        complete_fn = fn
    end

    return tk
end



return function()

local TL = {}


local task
local task_end

function TL.new_task(end_time)
    return create_task(end_time, TL)
end

function TL.add_task(tk)
    if task_end then
        task_end._next = tk
        task_end = tk
    else
        task = tk
        task_end = tk
        task._start()
    end
end

function TL.remove(tk)
    local start = task
    local pre = nil
    while start do
        if start == task then
            if start == task then
                task = start._next
            end
            if start == task_end then
                task_end = pre
            end
            if pre then
                pre._next = start._next
            end
            start:complete()
            break
        end
        pre = start
        start = start._next
    end
end

function TL._complete(tk)
    if task ~= tk then
        return false
    end
    if task == task_end then
        task_end = task._next
    end
    task = task._next
    if task then
        task._start()
    end
    return true
end

function TL.step(dt)
    if task then
        task._update(dt)
    end
end

function TL.add_space(t)
    if t <= 0 then
        t = 1
    end
    TL.add_task(TL.new_task(t))
end

function TL.add_fn(fn)
    local tk = TL.new_task(0)
    tk.on_start(function()
        fn()
        tk.complete()
    end)
    TL.add_task(tk)
end

function TL.clear()
    task = nil
    task_end = nil
end

return TL
end