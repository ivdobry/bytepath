Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    self.x = x
    self.y = y
    self.w = 12
    self.h = 12

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Player')

    self.r = -math.pi / 2
    self.rv = 1.66 * math.pi
    self.v = 0
    self.a = 100

    self.base_max_v = 100
    self.max_v = self.base_max_v

    self.max_hp = 100
    self.hp = self.max_hp

    self.max_ammo = 100
    self.ammo = self.max_ammo
    self.shoot_timer = 0
    self.shoot_cooldown = 0.24

    self.max_boost = 100
    self.boost = self.max_boost
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2


    self.trail_color = skill_point_color

    self.ship = 'Fighter'
    self:setAttack('Neutral')
    self.polygons = {}


    if self.ship == 'Fighter' then
        self.polygons[1] = {
            self.w, 0,
            self.w / 2, -self.w / 2,
            -self.w / 2, -self.w / 2,
            -self.w, 0,
            -self.w / 2, self.w / 2,
            self.w / 2, self.w / 2,
        }

        self.polygons[2] = {
            self.w / 2, -self.w / 2,
            0, -self.w,
            -self.w - self.w / 2, -self.w,
            -3 * self.w / 4, -self.w / 4,
            -self.w / 2, -self.w / 2,
        }

        self.polygons[3] = {
            self.w / 2, self.w / 2,
            -self.w / 2, self.w / 2,
            -3 * self.w / 4, self.w / 4,
            -self.w - self.w / 2, self.w,
            0, self.w,
        }
    end

    self.timer:every(0.01, function()
        if self.ship == 'Fighter' then
            self.area:addGameObject('TrailParticle',
                self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r - math.pi / 2),
                self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r - math.pi / 2),
                { parent = self, r = random(2, 4), d = random(0.15, 0.25), color = getColor(self.trail_color) })
            self.area:addGameObject('TrailParticle',
                self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r + math.pi / 2),
                self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r + math.pi / 2),
                { parent = self, r = random(2, 4), d = random(0.15, 0.25), color = getColor(self.trail_color) })
        else
            self.area:addGameObject('TrailParticle',
                self.x - self.w * math.cos(self.r), self.y - self.h * math.sin(self.r),
                { parent = self, r = random(2, 4), d = random(0.15, 0.25), color = getColor(self.trail_color) })
        end
    end)

    self.timer:every(5, function() self:tick() end)

    input:bind('f4', function() self:die() end)
end

function Player:update(dt)
    Player.super.update(self, dt)

    -- Shoot
    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown then
        self.shoot_timer = 0
        self:shoot()
    end

    -- Boost
    self.boost = math.min(self.boost + 10 * dt, self.max_boost)
    self.boost_timer = self.boost_timer + dt
    if self.boost_timer > self.boost_cooldown then self.can_boost = true end
    self.max_v = self.base_max_v
    self.boosting = false
    if input:down('up') and self.boost > 1 and self.can_boost then
        self.boosting = true
        self.max_v = 1.5 * self.base_max_v
        self.boost = self.boost - 50 * dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
        end
    end
    if input:down('down') and self.boost > 1 and self.can_boost then
        self.boosting = true
        self.max_v = 0.5 * self.base_max_v
        self.boost = self.boost - 50 * dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
        end
    end

    if self.boosting then
        self.trail_color = boost_color
    else
        self.trail_color = skill_point_color
    end

    -- Movement
    if input:down('left') then
        self.r = self.r - self.rv * dt
    end
    if input:down('right') then
        self.r = self.r + self.rv * dt
    end

    self.v = math.min(self.v + self.a * dt, self.max_v)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if self.collider:enter('Collectable') then
        local collision_data = self.collider:getEnterCollisionData('Collectable')
        local object = collision_data.collider:getObject()
        if object:is(Ammo) then
            object:die()
            self:addAmmo(5)
        end

        if object:is(Boost) then
            object:die()
            self:addBoost(25)
        end

        if object:is(HP) then
            object:die()
            self:addHP(25)
        end

        if object:is(SkillPoint) then
            object:die()
            self:addSP(1)
        end

        if object:is(Attack) then
            object:die()
            self:setAttack(object.attack)
        end
    end

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()

        self:hit(30)
    end

    if self.x < 0 then self:die() end
    if self.y < 0 then self:die() end
    if self.x > gw then self:die() end
    if self.y > gh then self:die() end
end

function Player:draw()
    if self.invisible then return end

    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(default_color)
    for _, vertice_group in ipairs(self.polygons) do
        local points = {}

        for i, point in ipairs(vertice_group) do
            if i % 2 == 1 then
                table.insert(points, self.x + point + random(-1, 1))
            else
                table.insert(points, self.y + point + random(-1, 1))
            end
        end

        love.graphics.polygon('line', points)
    end
    love.graphics.pop()
end

function Player:shoot()
    local d = 1.2 * self.w

    self.area:addGameObject('ShootEffect',
        self.x + d * math.cos(self.r), self.y + d * math.sin(self.r), { player = self, d = d })

    if self.attack == 'Neutral' then
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
    elseif self.attack == 'Double' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + math.pi / 12),
            self.y + 1.5 * d * math.sin(self.r + math.pi / 12),
            { r = self.r + math.pi / 12, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r - math.pi / 12),
            self.y + 1.5 * d * math.sin(self.r - math.pi / 12),
            { r = self.r - math.pi / 12, attack = self.attack })
    elseif self.attack == 'Triple' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + math.pi / 12),
            self.y + 1.5 * d * math.sin(self.r + math.pi / 12),
            { r = self.r + math.pi / 12, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r - math.pi / 12),
            self.y + 1.5 * d * math.sin(self.r - math.pi / 12),
            { r = self.r - math.pi / 12, attack = self.attack })
    elseif self.attack == 'Rapid' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
    elseif self.attack == 'Spread' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        local random_angle = random(-math.pi / 8, math.pi / 8)
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + random_angle),
            self.y + 1.5 * d * math.sin(self.r + random_angle),
            { r = self.r + random_angle, attack = self.attack })
    elseif self.attack == 'Back' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r - math.pi),
            self.y + 1.5 * d * math.sin(self.r - math.pi),
            { r = self.r - math.pi, attack = self.attack })
    elseif self.attack == 'Side' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r - math.pi / 2),
            self.y + 1.5 * d * math.sin(self.r - math.pi / 2),
            { r = self.r - math.pi / 2, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + math.pi / 2),
            self.y + 1.5 * d * math.sin(self.r + math.pi / 2),
            { r = self.r + math.pi / 2, attack = self.attack })
    end

    if self.ammo <= 0 then
        self:setAttack('Neutral')
        self.ammo = self.max_ammo
    end
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

function Player:addAmmo(amount)
    self.ammo = math.min(self.ammo + amount, self.max_ammo)
end

function Player:addBoost(amount)
    self.boost = math.min(self.boost + amount, self.max_boost)
end

function Player:addHP(amount)
    self.hp = math.min(self.hp + amount, self.max_hp)
end

function Player:removeHP(amount)
    self.hp = self.hp - amount

    if self.hp <= 0 then
        self:die()
    end
end

function Player:addSP(amount)
    skill_point = skill_point + amount
end

function Player:setAttack(attack)
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammo = self.max_ammo
end

function Player:hit(damage)
    damage = damage or 10

    if self.invincible then return end

    if damage >= 30 then
        self.invincible = true
        self.timer:after(2, function() self.invincible = false end)
        for i = 1, math.floor(50) do self.timer:after((i - 1) * 0.04, function() self.invisible = not self.invisible end) end
        self.timer:after((math.floor(50) + 1) * 0.04, function() self.invisible = false end)
        camera:shake(6, 60, 0.2)
        flash(3)
        slow(0.25, 0.5)
    else
        camera:shake(3, 60, 0.1)
        flash(2)
        slow(0.25, 0.5)
    end

    self:removeHP(damage)

    for i = 1, love.math.random(4, 8) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end
end
