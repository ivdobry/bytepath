Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.area:addPhisicsWorld()
    self.area.world:addCollisionClass('Player')
    self.area.world:addCollisionClass('Enemy')
    self.area.world:addCollisionClass('Projectile', { ignores = { 'Projectile' } })
    self.area.world:addCollisionClass('Collectable', { ignores = { 'Collectable', 'Projectile' } })
    self.area.world:addCollisionClass('EnemyProjectile', { ignores = { 'EnemyProjectile', 'Projectile', 'Enemy' } })

    self.timer = Timer()
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.player = self.area:addGameObject('Player', gw / 2, gh / 2)

    input:bind('p', function()
        self.area:addGameObject('Shooter')
    end)
end

function Stage:update(dt)
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw / 2, gh / 2)

    self.area:update(dt)
    self.timer:update(dt)
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()

    camera:attach(0, 0, gw, gh)
    self.area:draw()
    camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Stage:destroy()
    self.area:destroy()
    self.area = nil
end
