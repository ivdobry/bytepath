Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    self.x = x
    self.y = y
    self.w = 12
    self.h = 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    self.r = -math.pi / 2
    self.rv = 1.66 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100

    self.timer:every(0.24, function() self:shoot() end)
end

function Player:update(dt)
    Player.super.update(self, dt)

    if input:down('left') then
        self.r = self.r - self.rv * dt
    end
    if input:down('right') then
        self.r = self.r + self.rv * dt
    end

    self.v = math.min(self.v + self.a * dt, self.max_v)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if self.x < 0 then self:die() end
    if self.y < 0 then self:die() end
    if self.x > gw then self:die() end
    if self.y > gh then self:die() end
end

function Player:draw()
    love.graphics.circle('line', self.x, self.y, self.w)
    love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))
end

function Player:shoot()
    local d = 1.2 * self.w

    self.area:addGameObject('ShootEffect', self.x + d * math.cos(self.r),
        self.y + d * math.sin(self.r), { player = self, d = d })

    self.area:addGameObject('Projectile',
        self.x + 1.5 * d * math.cos(self.r),
        self.y + 1.5 * d * math.sin(self.r), { r = self.r })
end
