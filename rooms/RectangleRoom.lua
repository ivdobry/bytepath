RectangleRoom = Object:extend()

function RectangleRoom:new()
    self.x = 200
    self.y = 200
    self.width = 300
    self.heigt = 150
end

function RectangleRoom:update(dt)

end

function RectangleRoom:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.heigt)
end
