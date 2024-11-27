Object = require 'libraries/classic/classic'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Camera = require 'libraries/hump/camera'
Input = require 'libraries/boipushy/Input'
fn = require 'libraries/moses/moses'
wf = require 'libraries/windfield'

require 'GameObject'
require 'utils'
require 'globals'

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)
    local room_files = {}
    recursiveEnumerate('rooms', room_files)
    requireFiles(room_files)

    input = Input()
    camera = Camera()

    current_room = nil

    input:bind('a', 'left')
    input:bind('d', 'right')

    gotoRoom('Stage')
    resize(3)
end

function love.update(dx)
    camera:update(dx)

    if current_room then
        current_room:update(dx)
    end


    if love.keyboard.isDown('lctrl') and love.keyboard.isDown('w') then
        love.event.quit()
    end
end

function love.draw()
    if current_room then
        current_room:draw()
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
    if current_room and current_room.destroy then
        current_room:destroy()
    end

    current_room = _G[room_type](...)
end

function resize(s)
    love.window.setMode(s * gw, s * gh)
    sx, sy = s, s
end
