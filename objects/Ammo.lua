Ammo = GameObject:extend()

function Ammo:new(area, x, y, opts)
    Ammo.super.new(self, area, x, y, opts)

    self.w, self.h = 8, 8
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setFixedRotation(false)
    self.r = random(0, 2 * math.pi)
    self.v = random(10, 20)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:applyAngularImpulse(random(-24, 24))
end

function Ammo:draw()
    love.graphics.setColor(getColor(ammo_color))
    pushRotate(self.x, self.y, self.collider:getAngle())
    draft:rhombus(self.x, self.y, self.w, self.h, 'line')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end
