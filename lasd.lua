local lasd = {}

local lfs = require("lfs")

function lasd.load(fileName, directory, callback)
    local path = system.pathForFile(fileName, directory)
    local file = io.open(path, "r")
    
    if not file then
        path = nil
        if callback ~= nil then
            callback({status=404, output="none"})
        end
    else
        local content = file:read("*a")
        io.close(file)
        path = nil
        if callback ~= nil then
            callback({status=200, output=content})
        end
    end
end

function lasd.save(fileName, data, directory, callback)
    local path = system.pathForFile(fileName, directory)
    local file = io.open(path, "w")
    
    if file then
        file:write(data)
        io.close(file)
    end
    
    path = nil
    if callback ~= nil then
        callback({status=200})
    end
end

function lasd.createFolder(pathName, folderName, directory, callback)
    local path = system.pathForFile(pathName, directory)
    local success = lfs.chdir(path)
    if success then
        lfs.mkdir(folderName)
        if callback ~= nil then
            callback({status=200})
        end
    else
        if callback ~= nil then
            callback({status=403})
        end
    end
    path = nil
    success = nil
end

function lasd.removeFolder(pathName, folderName, directory, callback)
    local path = system.pathForFile(pathName, directory)
    local success = lfs.chdir(path)
    if success then
        lfs.rmdir(folderName)
        if callback ~= nil then
            callback({status=200})
        end
    else
        if callback ~= nil then
            callback({status=403})
        end
    end
    path = nil
    success = nil
end

function lasd.removeFile(pathName, directory, callback)
    local result, reason = os.remove(system.pathForFile(pathName, directory))
    if result then
        if callback ~= nil then
            callback({status=200})
        end
    else
        if callback ~= nil then
            callback({status=403, output="error! Reason: " .. reason})
        end
    end
    result = nil
end

function lasd.rename(oldPath, newPath, callback)
    local result, reason = os.rename(oldPath, newPath);
    if result == false then
        if callback then
            callback({status=403, output="error! Reason: " .. reason})
        end
    else
        if callback then
            callback({status=200})
        end
    end
end

function lasd.allFiles(pathName, directory, callback)
    local table = {files={}, directories={}, unknown={}}
    local path = system.pathForFile(pathName, directory)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local fullPath = path .. "/" .. file
            local attributes = lfs.attributes(fullPath)

            if attributes then
                if attributes.mode == "file" then
                    table.files[#table.files + 1] = file
                elseif attributes.mode == "directory" then
                    table.directories[#table.directories + 1] = file
                else
                    table.unknown[#table.unknown + 1] = {
                        name = file,
                        type = attributes.mode
                    }
                end
            end
        end
    end
    if callback ~= nil then
        callback({status=200, count={files=#table.files, directories=#table.directories, unknown=#table.unknown}, list=table})
    end
end

function lasd.version()
    print("Library version 1.4.1\n\n© Entaru Studios 2026")
end

return lasd