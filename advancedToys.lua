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

function M.version()
    print("LIBRARY VERSION 2.0.0 © Entaru Studios")
end

return M