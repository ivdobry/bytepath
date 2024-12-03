Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
    Projectile.super.new(self, area, x, y, opts)

    self.s = opts.s or 2.5
    self.v = opts.v or 200

    self.color = attacks[self.attack].color

    self.damage = 100

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    self.collider:setCollisionClass("Projectile")
end

function Projectile:update(dt)
    Projectile.super.update(self, dt)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()

        object:hit(self.damage)
        self:die()
    end

    if self.x < 0 then self:die() end
    if self.y < 0 then self:die() end
    if self.x > gw then self:die() end
    if self.y > gh then self:die() end
end

function Projectile:draw()
    love.graphics.setColor(getColor(default_color))

    pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())
    love.graphics.setLineWidth(self.s - self.s / 4)
    love.graphics.setColor(getColor(self.color))
    love.graphics.line(self.x - 2 * self.s, self.y, self.x, self.y)
    love.graphics.setColor(getColor(default_color))
    love.graphics.line(self.x, self.y, self.x + 2 * self.s, self.y)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
end

function Projectile:destroy()
    Projectile.super.destroy(self)
end

function Projectile:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y,
        { color = hp_color, w = 3 * self.s })
end
