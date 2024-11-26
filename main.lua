Object = require 'libraries/classic/classic'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Input = require 'libraries/boipushy/Input'
fn = require 'libraries/moses/moses'

function love.load()
    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)
    local room_files = {}
    recursiveEnumerate('rooms', room_files)
    requireFiles(room_files)

    current_room = nil

    gotoRoom('Stage')
end

function love.update(dx)
    if current_room then
        current_room:update(dx)
    end
end

function love.draw()
    if current_room then
        current_room:draw()
    end
end

function love.keypressed(key)
    if key == "f1" then
        gotoRoom("CircleRoom")
    end

    if key == "f2" then
        gotoRoom("RectangleRoom")
    end

    if key == "f3" then
        gotoRoom("PolygonRoom")
    end
end

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local fileInfo = love.filesystem.getInfo(file)
        if fileInfo.type == "file" then
            table.insert(file_list, file)
        elseif fileInfo.type == "directory" then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function gotoRoom(room_type, ...)
    current_room = _G[room_type](...)
end
