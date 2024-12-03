EnemyDeathEffect = GameObject:extend()

function EnemyDeathEffect:new(area, x, y, opts)
    EnemyDeathEffect.super.new(self, area, x, y, opts)

    self.first = true
    self.timer:after(0.1, function()
        self.first = false
        self.second = true
        self.timer:after(0.15, function()
            self.second = false
            self.dead = true
        end)
    end)
end

function EnemyDeathEffect:update(dt)
    EnemyDeathEffect.super.update(self, dt)
end

function EnemyDeathEffect:draw()
    love.graphics.setColor(getColor(self.color))
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    love.graphics.setColor(getColor(default_color))
end

function EnemyDeathEffect:destroy()
    EnemyDeathEffect.super.destroy(self)
end
