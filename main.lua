local sk = require("sk")
local at = require("advancedToys")
local lasd = require("lasd")
local json = require("json")
local physics = require("physics")

local version = "1.1.0"

function startBoot(command, message)
    local scene = display.newGroup();
    local key
    local mouse

    function stopBoot()
        display.remove(scene);
        Runtime:removeEventListener("mouse", mouse)
        Runtime:removeEventListener("key", keyboard)
    end

    local outputText = display.newEmbossedText({parent=scene, text="© Entaru Studios 2026 | Version: " .. version .. "\n> ", x=10, y=10, width=display.actualContentWidth-20, font="font.ttf", fontSize=30, align="left"});
    outputText.anchorX = 0; outputText.anchorY = 0;
    if message then
        outputText.text = message .. "\n"
    end
    local mainText = outputText.text
    local enteredText = command or ""
    outputText.text = "© Entaru Studios 2026 | Version: " .. version .. "\n> " .. enteredText

    mouse = function(event)
        outputText.y = outputText.y - (event.scrollY/2)
    end
    Runtime:addEventListener("mouse", mouse)

    keyboard = function(event)
        if event.phase == "down" and event.keyName ~= "enter" and event.keyName ~= "deleteBack" then
            event.keyName = event.keyName:gsub("space", " ")
            local allowed = {
                a=true,b=true,c=true,d=true,e=true,f=true,g=true,h=true,
                i=true,j=true,k=true,l=true,m=true,n=true,o=true,p=true,
                q=true,r=true,s=true,t=true,u=true,v=true,w=true,x=true,
                y=true,z=true,
                A=true,B=true,C=true,D=true,E=true,F=true,G=true,H=true,
                I=true,J=true,K=true,L=true,M=true,N=true,O=true,P=true,
                Q=true,R=true,S=true,T=true,U=true,V=true,W=true,X=true,
                Y=true,Z=true,
                ["0"]=true,["1"]=true,["2"]=true,["3"]=true,["4"]=true,
                ["5"]=true,["6"]=true,["7"]=true,["8"]=true,["9"]=true,
                ["-"]=true,["="]=true,["["]=true,["]"]=true,["\\"]=true,
                [";"]=true,["'"]=true,[","]=true,["."]=true,["/"]=true,
                [" "]=true,["`"]=true,["~"]=true,["!"]=true,["@"]=true,
                ["#"]=true,["$"]=true,["%"]=true,["^"]=true,["&"]=true,
                ["*"]=true,["("]=true,[")"]=true,["_"]=true,["+"]=true,
                ["{"]=true,["}"]=true,[":"]=true,["\""]=true,["\\"]=true,
                ["<"]=true,[">"]=true,["?"]=true
            }
            if event.isShiftDown == true then
                event.keyName = string.upper(event.keyName)
                if event.keyName == "`" then
                    event.keyName = "~"
                elseif event.keyName == "1" then
                    event.keyName = "!"
                elseif event.keyName == "2" then
                    event.keyName = "@"
                elseif event.keyName == "3" then
                    event.keyName = "#"
                elseif event.keyName == "4" then
                    event.keyName = "$"
                elseif event.keyName == "5" then
                    event.keyName = "%"
                elseif event.keyName == "6" then
                    event.keyName = "^"
                elseif event.keyName == "7" then
                    event.keyName = "&"
                elseif event.keyName == "8" then
                    event.keyName = "*"
                elseif event.keyName == "9" then
                    event.keyName = "("
                elseif event.keyName == "0" then
                    event.keyName = ")"
                elseif event.keyName == "[" then
                    event.keyName = "{"
                elseif event.keyName == "]" then
                    event.keyName = "}"
                elseif event.keyName == "-" then
                    event.keyName = "_"
                elseif event.keyName == "+" then
                    event.keyName = "="
                elseif event.keyName == ";" then
                    event.keyName = ":"
                elseif event.keyName == "'" then
                    event.keyName = "\""
                elseif event.keyName == "\\" then
                    event.keyName = "|"
                elseif event.keyName == "," then
                    event.keyName = "<"
                elseif event.keyName == "." then
                    event.keyName = ">"
                elseif event.keyName == "/" then
                    event.keyName = "?"
                end
            end
            if allowed[event.keyName] and allowed[event.keyName] == true then
                enteredText = enteredText .. event.keyName
                outputText.text = mainText .. enteredText
            end
        elseif event.phase == "down" and event.keyName == "deleteBack" then
            enteredText = string.sub(enteredText, 1, -2)
            outputText.text = mainText .. enteredText
        elseif event.phase == "down" and event.keyName == "enter" then
            mainText = mainText .. enteredText .. "\n"
            outputText.text = mainText

            local command = enteredText:split(" ")
            enteredText = ""

            local answer = ""

            if command[1] == "start" then
                if command[2] then
                    local function startFile(event)
                        if event.status == 404 then
                            answer = "File " .. command[2] .. " not founded"
                        elseif event.status == 200 then
                            local allow = {
                                sk = sk,
                                physics = physics,
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
                            local startCode = loadstring(event.output)
                            if startCode then
                                setfenv(startCode, allow);
                                allow._G = allow
                                local result, reason = pcall(startCode)
                                if result == false then
                                    answer = "Failed to start. Reason: " .. (reason or "no reason")
                                    sk.closeAll()
                                else
                                    stopBoot()
                                end
                            else
                                answer = "Error loading start file"
                            end
                        else
                            answer = "Unknown error: " .. (event.status or "no status")
                        end
                    end
                    lasd.load(command[2], system.DocumentsDirectory, startFile)
                else
                    answer = "Please, enter file path"
                end
            elseif command[1] == "boot" then
                local function bootFile(event)
                    if event.status == 404 then
                        answer = "File boot.txt not founded"
                    elseif event.status == 200 then
                        local loadFileName = event.output
                        local function loadCode(event)
                            if event.status == 404 then
                                answer = "File " .. loadFileName .. " not founded"
                            elseif event.status == 200 then
                                local allow = {
                                    sk = sk,
                                    timer = timer,
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
                                local startCode = loadstring(event.output)
                                if startCode then
                                    setfenv(startCode, allow);
                                    allow._G = allow
                                    local result, reason = pcall(startCode)
                                    if result == false then
                                        answer = "Failed to start. Reason: " .. (reason or "no reason")
                                        sk.closeAll()
                                    else
                                        stopBoot()
                                    end
                                else
                                    answer = "Error loading start file"
                                end
                            else
                                answer = "Unknown error: " .. (event.status or "no status")
                            end
                        end
                        lasd.load(event.output, system.DocumentsDirectory, loadCode)
                    else
                        answer = "Unknown error: " .. (event.status or "no status")
                    end
                end
                lasd.load("boot.txt", system.DocumentsDirectory, bootFile)
            elseif command[1] == "file" then
                if command[2] == "open" then
                    if command[3] then
                        lasd.load(command[3], system.DocumentsDirectory, function(event)
                            if event.status == 404 then
                                answer = "File " .. command[3] .. " not founded"
                            elseif event.status == 200 then
                                answer = "Data in " .. command[3] .. ":\n" .. event.output or "no data"
                            else
                                answer = "Unknown error: " .. (event.status or "no status")
                            end
                        end)
                    else
                        answer = "Please, enter file path"
                    end
                elseif command[2] == "create" or command[2] == "edit" then
                    if command[3] then
                        if command[4] then
                            lasd.save(command[3], command[4], system.DocumentsDirectory)
                            answer = "File saved in path: " .. command[3]
                        else
                            answer = "Please, enter file data"
                        end
                    else
                        answer = "Please, enter file path"
                    end
                elseif command[2] == "removeFile" then
                    if command[3] then
                        lasd.removeFile(command[3], system.DocumentsDirectory, function(event)
                            if event.status == 200 then
                                answer = "File " .. command[3] .. " successful removed"
                            elseif event.status == 403 then
                                answer = "Permission denied"
                            else
                                answer = "Unknown error: " .. (event.status or "no status")
                            end
                        end)
                    else
                        answer = "Please, enter file path"
                    end
                elseif command[2] == "removeFolder" then
                    if command[3] then
                        if command[4] then
                            lasd.allFiles(command[3], system.DocumentsDirectory, function(event)
                                if event.count == 0 then
                                    lasd.removeFolder(command[3], command[4], system.DocumentsDirectory, function(event)
                                        if event.status == 200 then
                                            answer = "Folder removed successfully"
                                        elseif event.status == 403 then
                                            answer = "Permission denied"
                                        else
                                            answer = "Unknown error: " .. (event.status or "no status")
                                        end
                                    end)
                                else
                                    answer = "You need to remove all files in this folder"
                                end
                            end)
                        else
                            answer = "Please, enter folder name"
                        end
                    else
                        answer = "Please, enter path to folder"
                    end
                elseif command[2] == "rename" then
                    if command[3] then
                        if command[4] then
                            local result, reason = os.rename(command[3], command[4]);
                            if result == false then
                                answer = "Failed rename " .. command[3] .. " to " .. command[4] .. ". Reason: " .. reason
                            else
                                answer = command[3] .. " renamed to " .. command[4] .. " successfully"
                            end
                        else
                            answer = "Please, enter new path"
                        end
                    else
                        answer = "Please, enter old path"
                    end
                elseif command[2] == "list" then
                    if command[3] then
                        lasd.allFiles(command[3], system.DocumentsDirectory, function(event)
                            answer = "Total folders in " .. command[3] .. ": " .. event.count.directories .. "\n    " .. table.concat(event.list.directories, "\n    ") .. "\nTotal files in " .. command[3] .. ": " .. event.count.files .. "\n    " .. table.concat(event.list.files, "\n    ") .. "\nTotal unknown files in " .. command[3] .. ": " .. event.count.unknown .. "\n    " .. table.concat(event.list.unknown, "\n    ")
                        end)
                    else
                        answer = "Please, enter path"
                    end
                else
                    answer = "Unknown action with file: " .. (command[2] or "")
                end
            elseif command[1] == "reboot" then
                answer = "Reboot..."
                stopBoot()
                startBoot("boot")
            elseif command[1] == "commandlist" or command[1] == "help" then
                answer = [[
Command list:
    start [pathToFile]
    boot
    file open [pathToFile]
    file create [pathToFile] [data]
    file edit [pathToFile] [data]
    file removeFile [pathToFile]
    file removeFolder [pathToFile] [pathToFolder]
    file rename [oldPath] [newPath]
    file list [path]
    download [link] [path] [filename]
    libs [libraryName]
    reboot
    help
    commandlist]]
            elseif command[1] == "altf4" then
                native.requestExit();
            elseif command[1] == "download" then
                local function listener(event)
                    if event.status == 200 then
                        answer = "Successful"
                        mainText = mainText .. answer .. "\n> "
                        outputText.text = mainText
                    else
                        answer = "Error " .. (event.status or "unknown")
                        mainText = mainText .. answer .. "\n> "
                        outputText.text = mainText
                    end
                end
                answer = "Downloading..."
                network.download(command[2], "GET", listener, command[3] .. "/" .. command[4], system.DocumentsDirectory);
            elseif command[1] == "libs" then
                answer = "Libraries in system:\nLASD\nAdavancedToys"
                if command[2] then
                    if command[2] == "LASD" then
                        answer = "LASD is a library for quickly editing and manipulating data."
                    elseif command[2] == "AdavancedToys" then
                        answer = "AdavancedToys is a library adding advanced features to Solar2D"
                    else
                        answer = "Unknown library: " .. command[2]
                    end
                end
            else
                if not command[1] then
                    command[1] = ""
                end
                answer = "Unknown command: " .. command[1]
            end
            mainText = mainText .. answer .. "\n> "
            outputText.text = mainText
        end
    end
    Runtime:addEventListener("key", keyboard)
end
startBoot("boot")