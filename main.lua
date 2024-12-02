Object = require 'libraries/classic/classic'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Camera = require 'libraries/hump/camera'
Input = require 'libraries/boipushy/Input'
fn = require 'libraries/moses/moses'
wf = require 'libraries/windfield'
draft = require('libraries/draft/draft')()
Vector = require 'libraries/hump/vector'

require 'GameObject'
require 'utils'
require 'globals'
require 'libraries/utf8'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')

    loadFonts('resources/fonts')
    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)
    local room_files = {}
    recursiveEnumerate('rooms', room_files)
    requireFiles(room_files)

    input = Input()
    camera = Camera()
    timer = Timer()

    current_room = nil
    slow_amount = 1
    flas_frames = nil

    input:bind('a', 'left')
    input:bind('d', 'right')
    input:bind('w', 'up')
    input:bind('s', 'down')

    gotoRoom('Stage')
    resize(3)
end

function love.update(dt)
    camera:update(dt * slow_amount)
    timer:update(dt * slow_amount)

    if current_room then
        current_room:update(dt)
    end


    if love.keyboard.isDown('lctrl') and love.keyboard.isDown('w') then
        love.event.quit()
    end

    if current_room then current_room:update(dt * slow_amount) end
end

function love.draw()
    if current_room then
        current_room:draw()
    end

    if flash_frames then
        flash_frames = flash_frames - 1
        if flash_frames == -1 then flash_frames = nil end
    end
    if flash_frames then
        love.graphics.setColor(getColor(background_color))
        love.graphics.rectangle('fill', 0, 0, sx * gw, sy * gh)
        love.graphics.setColor(255, 255, 255)
    end
end

-- Load --

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local fileInfo = love.filesystem.getInfo(file)
        if fileInfo.type == 'file' then
            table.insert(file_list, file)
        elseif fileInfo.type == 'directory' then
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

function loadFonts(path)
    fonts = {}
    local font_paths = {}
    recursiveEnumerate(path, font_paths)
    for i = 8, 16, 1 do
        for _, font_path in pairs(font_paths) do
            local last_forward_slash_index = font_path:find("/[^/]*$")
            local font_name = font_path:sub(last_forward_slash_index + 1, -5)
            local font = love.graphics.newFont(font_path, i)
            font:setFilter('nearest', 'nearest')
            fonts[font_name .. '_' .. i] = font
        end
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

function slow(amount, duration)
    slow_amount = amount
    timer:tween('slow', duration, _G, { slow_amount = 1 }, 'in-out-cubic')
end

function flash(frames)
    flas_frames = frames
end
