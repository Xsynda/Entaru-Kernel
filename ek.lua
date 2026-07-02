local M = {}

local lasd = require("lasd")
local at = require("advancedToys")
local json = require("json")
local physics = require("physics")
local widget = require("widget")
local lfs = require("lfs")

local listeners = {}
local timers = {}
local catchErrors
local maingroup = display.newGroup();

M = {
    screenWidth = display.safeActualContentWidth,
    screenHeight = display.safeActualContentHeight,
    zeroX = display.safeScreenOriginX,
    zeroY = display.safeScreenOriginY,
    contentScale = display.contentScaleX,
    display = {},
    timer = {},
    fs = {}
}

function M.display.newObject(objType, params)
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
        obj = display.newImage(unpack(params));
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

function M.display.removeObject(obj)
    if obj then
        maingroup:remove(obj)
        display.remove(obj)
    end
end

function M.print(...)
    native.showAlert("Entaru Kernel", table.concat({...}, " "), {"OK"})
    print(...)
end

M.physics = physics
M.audio = audio
M.graphics = graphics
M.json = json
M.math = math
M.string = string
M.table = table
M.transition = transition
M.os = {clock = os.clock, date = os.date, difftime = os.difftime, time = os.time}
M.at = at

function M.addEventListener(object, event, listener)
    object:addEventListener(event, listener)
    table.insert(listeners, {object, event, listener})
end

function M.removeEventListener(object, event, listener)
    for k, v in pairs(listeners) do
        if v[1] == object and v[2] == event and v[3] == listener then
            v[1]:removeEventListener(v[2], v[3])
            table.remove(listeners, k)
            break
        end
    end
end

function M.timer.newTimer(delay, callback, iterations)
    local timer = timer.performWithDelay(delay, callback, iterations)
    table.insert(timers, timer);
    return timer
end

function M.timer.cancelTimer(timer)
    timer.cancel(timer)
    table.remove(timers, timer)
end

function M.timer.cancelAllTimers()
    for i, v in ipairs(timers) do
        timer.cancel(v)
        table.remove(timers, i)
    end
end

function M.fs.openFile(path, callback)
    local file = io.open(system.pathForFile(path, system.DocumentsDirectory), "r")
    if file then
        local data = file:read("*all")
        file:close()
        if callback then
            callback({status = "done", data = data})
        end
    else
        if callback then
            callback({status = "error", data = "File not found or unknown error"})
        end
    end
end

function M.fs.writeFile(path, data)
    local file = io.open(system.pathForFile(path, system.DocumentsDirectory), "w")
    if file then
        file:write(data)
        file:close()
    end
end

function M.fs.newFolder(path, folderName, callback)
    lasd.createFolder(path, folderName, system.DocumentsDirectory, callback)
end

function M.fs.deleteFileOrFolder(path)
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

function M.fs.renameFile(oldPath, newPath)
    local oldFile = io.open(system.pathForFile(oldPath, system.DocumentsDirectory), "r")
    if oldFile then
        local data = oldFile:read("*all")
        oldFile:close()
        M.saveFile(newPath, data)
        M.deleteFile(oldPath)
    end
end

function M.fs.listFiles(path, callback)
    local function list(event)
        callback(event)
    end
    lasd.allFiles(path, system.DocumentsDirectory, list)
end

function M.requireScript(path, localG)
    local function scriptLoad(event)
        if event.status == 200 then
            local script = event.output
            local allow = {
                KERVER = version,
                ek = M,
                assert = assert,
                collectgarbage = collectgarbage,
                ipairs = ipairs,
                next = next,
                pairs = pairs,
                pcall = pcall,
                rawequal = rawequal,
                rawget = rawget,
                rawset = rawset,
                select = select,
                setfenv = setfenv,
                tonumber = tonumber,
                tostring = tostring,
                type = type,
                unpack = unpack
            }
            local scriptCode = loadstring(script)
            if script then
                setfenv(scriptCode, localG or allow);
                allow._G = localG or allow
                local success, result = pcall(scriptCode)
                if not success then
                    return nil, result
                else
                    return result
                end
            end
        else
            return nil
        end
    end
    lasd.load(path, system.DocumentsDirectory, scriptLoad)
end

function M.requireModule(path, localG)
    return M.requireScript(path, localG)
end

function M.display.loadFont(fontName, fontPath)
    local file = io.open(system.pathForFile(fontPath, system.DocumentsDirectory), "rb")
    if file then
        local fontData = file:read("*all")
        file:close()
        newFile = io.open(system.pathForFile("fonts/", system.ResourceDirectory) .. fontName, "wb")
        if newFile then
            newFile:write(fontData)
            newFile:close()
        end
    end
end

function M.kerdir()
    return system.ResourceDirectory
end

function M.sysdir()
    return system.DocumentsDirectory
end

function M.closeAll()
    display.remove(maingroup)
    for k, v in pairs(listeners) do
        v[1]:removeEventListener(v[2], v[3])
        table.remove(listeners, k)
    end
    for i, v in ipairs(timers) do
        timer.cancel(v)
        table.remove(timers, i)
    end
end

function M.removeScene()
    M.closeAll()
    maingroup = display.newGroup();
end

function M.shutdown()
    M.closeAll()
    startBoot("boot")
end

function catchErrors(event)
    M.closeAll()
    startBoot("boot", "We're catch an error. Reason: " .. event.errorMessage)
end

function M.version()
    return "1.1.0"
end

return M