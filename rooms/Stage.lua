Stage = Object:extend()

function Stage:new()
    self.area = Area()
    self.timer = Timer()
    self.timer:every(2, function()
        self.area:addGameObject('Circle', random(0, 800), random(0, 600))
    end)
end

function Stage:update(dt)
    self.area:update(dt)
    self.timer:update(dt)
end

function Stage:draw()
    self.area:draw()
end
