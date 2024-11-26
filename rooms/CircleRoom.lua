CircleRoom = Object:extend()

function CircleRoom:new()
    self.x = 200
    self.y = 200
    self.radius = 200
end

function CircleRoom:update(dt)

end

function CircleRoom:draw()
    love.graphics.circle("line", self.x, self.y, self.radius)
end
