HPEffect = GameObject:extend()

function HPEffect:new(area, x, y, opts)
    HPEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    self.w = 1.5 * self.w
    self.h = self.w

    self.current_color = default_color
    self.timer:after(0.2, function()
        self.current_color = self.color
        self.timer:after(0.35, function()
            self.dead = true
        end)
    end)

    self.visible = true
    self.timer:after(0.2, function()
        self.timer:every(0.05, function() self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)
    end)

    self.sx, self.sy = 1, 1
    self.timer:tween(0.35, self, { sx = 2, sy = 2 }, 'in-out-cubic')
end

function HPEffect:update(dt)
    HPEffect.super.update(self, dt)
end

function HPEffect:draw()
    if not self.visible then return end

    love.graphics.setColor(getColor(self.current_color))
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - 2, self.w, 4)
    love.graphics.rectangle('fill', self.x - 2, self.y - self.h / 2, 4, self.h)
    love.graphics.setColor(getColor(default_color))
    draft:circle(self.x, self.y, self.sx * self.w, self.sy * 1 * self.h, 'line')
end

function HPEffect:destroy()
    HPEffect.super.destroy(self)
end
