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
    self.a = 100

    self.base_max_v = 100
    self.max_v = self.base_max_v

    self.trail_color = skill_point_color

    self.timer:every(0.01, function()
        self.area:addGameObject('TrailParticle',
            self.x - self.w * math.cos(self.r), self.y - self.h * math.sin(self.r),
            { parent = self, r = random(2, 4), d = random(0.15, 0.25), color = getColor(self.trail_color) })
    end)


    self.timer:every(0.24, function() self:shoot() end)
    self.timer:every(5, function() self:tick() end)

    input:bind('f4', function() self:die() end)
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

    self.max_v = self.base_max_v
    self.boosting = false
    if input:down('up') then
        self.boosting = true
        self.max_v = 1.5 * self.base_max_v
    end
    if input:down('down') then
        self.boosting = true
        self.max_v = 0.5 * self.base_max_v
    end
    self.trail_color = skill_point_color
    if self.boosting then self.trail_color = boost_color end

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

function Player:die()
    self.dead = true

    flash(4)
    camera:shake(6, 60, 0.4)
    slow(0.1, 1)

    for i = 1, love.math.random(4, 8) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end
end

function Player:tick()
    self.area:addGameObject('TickEffect', self.x, self.y, { parent = self })
end
