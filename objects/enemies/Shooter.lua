Shooter = GameObject:extend()

function Shooter:new(area, x, y, opts)
    Shooter.super.new(self, area, x, y, opts)

    self.hp = 100

    self.s = opts.s or 2.5
    self.v = opts.v or 200

    local direction = table.random({ -1, 1 })
    self.x = gw / 2 + direction * (gw / 2 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 12, 6
    self.collider = self.area.world:newPolygonCollider(
        { self.w, 0, -self.w / 2, self.h, -self.w, 0, -self.w / 2, -self.h })
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Enemy')

    self.v = -direction * random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-100, 100))
    self.collider:setFixedRotation(false)
    self.collider:setAngle(direction == -1 and 0 or math.pi)
    self.collider:setFixedRotation(true)
end

function Shooter:update(dt)
    Shooter.super.update(self, dt)
end

function Shooter:draw()
    love.graphics.setColor(getColor(hp_color))
    if self.hit_flash then love.graphics.setColor(getColor(default_color)) end
    local points = { self.collider:getWorldPoints(self.collider.shapes.main:getPoints()) }
    love.graphics.polygon('line', points)
    love.graphics.setColor(getColor(default_color))
end

function Shooter:hit(damage)
    damage_done = damage or 100

    self.hp = self.hp - damage_done


    if self.hp <= 0 then
        self:die()
    else
        self.hit_flash = true
        self.timer:after("hit_flash", 0.2, function() self.hit_flash = false end)
    end
end

function Shooter:die()
    self.dead = true
    self.area:addGameObject('EnemyDeathEffect', self.x, self.y,
        { color = hp_color, w = 3 * self.s })
end