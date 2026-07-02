local M = {}

function M.rotateTo(target, x, y)
    if not target then
        error("Target не задана", 1);
    elseif target then
        if not x then
            error("X не задан", 1);
        elseif x then
            if not y then
                error("Y не задан", 1);
            elseif y then
                local dx = x - target.x
                local dy = y - target.y
                local angleRad = math.atan2(dy, dx)
                target.rotation = math.deg(angleRad)
            end
        end
    end
end

function M.moveByRotation(target, mode)
    if not target then
        error("Target не задан", 2)
    elseif target then
        if not mode then
            error("Mode не задан", 2)
        elseif mode then
            local angleRad = math.rad(target.rotation)
            local vx = math.cos(angleRad) * target.speed
            local vy = math.sin(angleRad) * target.speed
            if mode == "default" then
                target.x = target.x + vx * (1/display.fps)
                target.y = target.y + vy * (1/display.fps)
            elseif mode == "physics" then
                target:setLinearVelocity(vx, vy)
            end
        end
    end
end

function string:split(pattern)
    if not pattern then
        error("pattern не задан")
    elseif pattern then
        local result = {}
        for value in string.gmatch(self, "([^"..pattern.."]+)") do
            result[#result+1] = value
        end
        return result
    end
end

function M.contains(self, x, y)
    if (x < self.contentBounds.xMax and x > self.contentBounds.xMin) and (y < self.contentBounds.yMax and y > self.contentBounds.yMin) then
        return true
    else
        return false
    end
end

function M.setButtonListener(target, listener)
    local function touchListener(event)
        if event.phase == "began" then
            listener(event)
            display.getCurrentStage():setFocus(event.target, event.id)
            return true
        elseif event.phase == "moved" then
            listener(event)
        elseif event.phase == "ended" then
            listener(event)
            display.getCurrentStage():setFocus(nil, event.id)
        end
    end
    target:addEventListener("touch", touchListener)
end

function M.formatValue(value, letterTable)
    if value and letterTable and type(value) == "number" then
        if value >= 1000000000000 then
            return string.format("%.1f"..letterTable.trillion, value/1000000000000)
        elseif value >= 1000000000 then
            return string.format("%.1f"..letterTable.billion, value/1000000000)
        elseif value >= 1000000 then
            return string.format("%.1f"..letterTable.million, value/1000000)
        elseif value >= 1000 then
            return string.format("%.1f"..letterTable.thousand, value/1000)
        else
            return tostring(value)
        end
    end
end

function M.version()
    print("LIBRARY VERSION 2.3.0 © Entaru Studios")
    return "2.3.0", 2
end

return M