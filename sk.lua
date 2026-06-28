local sk = {}

local lasd = require("lasd")
local physics = require("physics")
local widget = require("widget")
local lfs = require("lfs")

local listeners = {}
local timers = {}
local catchErrors
local maingroup = display.newGroup();

sk = {
    screenWidth = display.safeActualContentWidth,
    screenHeight = display.safeActualContentHeight,
    zeroX = display.safeScreenOriginX,
    zeroY = display.safeScreenOriginY,
    contentScale = display.contentScaleX
}

function sk.newObject(objType, params)
    local obj
    if objType == "rect" then
        obj = display.newRect(unpack(params));
    elseif objType == "roundedRect" then
        obj = display.newRoundedRect(params);
    elseif objType == "circle" then
        obj = display.newCircle(params);
    elseif objType == "group" then
        obj = display.newGroup();
    elseif objType == "image" then
        obj = display.newImage(params);
    elseif objType == "imageRect" then
        obj = display.newImageRect(params);
    elseif objType == "line" then
        obj = display.newLine(unpack(params));
    elseif objType == "mesh" then
        obj = display.newMesh(params);
    elseif objType == "sprite" then
        obj = display.newSprite(params);
    elseif objType == "text" then
        obj = display.newText(params);
    elseif objType == "embossedText" then
        obj = display.newEmbossedText(params);
    elseif objType == "scroll" then
        obj = widget.newScrollView(params);
    elseif objType == "spinner" then
        obj = widget.newSpinner(params);
    elseif objType == "stepper" then
        obj = widget.newStepper(params);
    elseif objType == "tabBar" then
        obj = widget.newTabBar(params);
    elseif objType == "slider" then
        obj = widget.newSlider(params);
    elseif objType == "switch" then
        obj = widget.newSwitch(params);
    elseif objType == "pickerWheel" then
        obj = widget.newPickerWheel(params);
    elseif objType == "progressView" then
        obj = widget.newProgressView(params);
    end
    
    maingroup:insert(obj)
    return obj
end

sk.physics = physics
sk.audio = audio
sk.graphics = graphics
sk.json = json
sk.math = math
sk.string = string
sk.table = table
sk.os = {clock = os.clock, date = os.date, difftime = os.difftime, time = os.time}

function sk.addEventListener(object, event, listener)
    object:addEventListener(event, listener)
    table.insert(listeners, {object, event, listener})
end

function sk.removeEventListener(object, event, listener)
    for k, v in pairs(listeners) do
        if v[1] == object and v[2] == event and v[3] == listener then
            v[1]:removeEventListener(v[2], v[3])
            table.remove(listeners, k)
            break
        end
    end
end

function sk.timer(delay, callback, iterations)
    local timer = timer.performWithDelay(delay, callback, iterations)
    table.insert(timers, timer);
    return timer
end

function sk.cancelTimer(timer)
    timer.cancel(timer)
    table.remove(timers, timer)
end

function sk.cancelAllTimers()
    for i, v in ipairs(timers) do
        timer.cancel(v)
        table.remove(timers, i)
    end
end

function sk.loadFile(path, callback)
    local file = io.open(system.pathForFile(path, system.DocumentsDirectory), "r")
    if file then
        local data = file:read("*all")
        file:close()
        if callback then
            callback(data)
        end
    end
end

function sk.saveFile(path, data)
    local file = io.open(system.pathForFile(path, system.DocumentsDirectory), "w")
    if file then
        file:write(data)
        file:close()
    end
end

function sk.deleteFile(path)
    local function deleteDir(name)
        local path = system.pathForFile(name, system.DocumentsDirectory)
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local full = path .. "/" .. file
                if lfs.attributes(full, "mode") == "directory" then
                    deleteDir(full)
                else
                    os.remove(full)
                end
            end
        end
        os.remove(path)
    end
    deleteDir(path)
end

function sk.renameFile(oldPath, newPath)
    local oldFile = io.open(system.pathForFile(oldPath, system.DocumentsDirectory), "r")
    if oldFile then
        local data = oldFile:read("*all")
        oldFile:close()
        sk.saveFile(newPath, data)
        sk.deleteFile(oldPath)
    end
end

function sk.list(path)
    local function list(event)
        return event
    end
    lasd.allFiles(path, system.DocumentsDirectory, list)
end

function sk.kerdir()
    return system.ResourceDirectory
end

function sk.sysdir()
    return system.DocumentsDirectory
end

function sk.closeAll()
    display.remove(maingroup)
    for k, v in pairs(listeners) do
        v[1]:removeEventListener(v[2], v[3])
    end
    for i, v in ipairs(timers) do
        timer.cancel(v)
        table.remove(timers, i)
    end
end

function catchErrors(event)
    sk.closeAll()
    startBoot("boot", "We're catch an error. Reason: " .. event.errorMessage)
end

function sk.version()
    return "1.0.0"
end

return sk