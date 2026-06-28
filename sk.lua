local sk = {}

local lasd = require("lasd")
local physics = require("physics")
local widget = require("widget")

local listeners = {}
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

function sk.kerdir()
    return system.ResourceDirectory
end

function sk.sysdir()
    return system.DocumentsDirectory
end

function sk.closeAll()
    display.remove(maingroup)
    for k, v in pairs(listeners) do
        k:removeEventListener(v[1], v[2])
    end
end

function catchErrors(event)
    sk.closeAll()
    startBoot("boot", "We're catch an error. Reason: " .. event.errorMessage)
end

return sk