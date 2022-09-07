Global = {}
Global.Elapsed = 0;

function deepcompare(o1,o2,ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or deepcompare(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function has_value (tab, val, doDeepCompare)
    for index, value in ipairs(tab) do
        if(doDeepCompare)        then
            return deepcompare(value,val,true)
        else
            if value == val then
                return true
            end
        end
    end

    return false
end

function dump(o, currentRecurse)
    if(currentRecurse == nil)then
        currentRecurse = 0
    end

    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then 
            k = '"'..k..'"' 
        end
        if(currentRecurse < 100)then
            currentRecurse = currentRecurse + 1
            s = s .. '['..k..'] = ' .. dump(v, currentRecurse) .. ',' -- .. '\n'
        else
            s = s .. '['..k..'] = ' .. 'MAX RECURSE ACHIEVED'
        end
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function DebugDump(o, message)
    if(message == nil)then
        message = ""
    end
    DebugPrint(message .. dump(o))
end

function Uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function round(exact, quantum)
    local quant,frac = math.modf(exact/quantum)
    return quantum * (quant + (frac > 0.5 and 1 or 0))
end

function is_array(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
  end

function GetAimPos()
    local ct = GetPlayerCameraTransform()
    local forwardPos = TransformToParentPoint(ct, Vec(0, 0, -150))
    local direction = VecSub(forwardPos, ct.pos)
    local distance = VecLength(direction)
    local direction = VecNormalize(direction)
    --QueryRejectBody(sb)
    local hit, hitDistance = QueryRaycast(ct.pos, direction, distance)
    if hit then
        forwardPos = TransformToParentPoint(ct, Vec(0, 0, -hitDistance))
        distance = hitDistance
    end
    return forwardPos, hit, distance
end

function wait(seconds)
    local start = os.time()
    repeat until os.time() > start + seconds
end

function getRandomItem(t)
    return t[ math.random( #t ) ]
end



TimerManager = {
    Timers = {}
}

function TimerManager.RegisterTimer(functionAction, interval, once)
    table.insert( TimerManager.Timers, {Action = functionAction,Interval = interval, Once = once, LastProcessed = 0} )
end

function TimerManager.Update(elapsedTime)
    for index, value in pairs(TimerManager.Timers) do
       
        if elapsedTime >= value.LastProcessed + value.Interval then
            DebugPrint(elapsedTime ..  ">=" .. value.LastProcessed + value.Interval)
            value.Action()
            value.LastProcessed = elapsedTime
            if value.Once then
                table.remove( TimerManager.Timers, index)
            end
        end
    end
end
