local Object = Object or require "lib/classic"

local Hud = Object:extend()

function Hud:new(boss, character)

    self.boss = boss
    self.character = character

    self.barraAncho = 600
    self.barraAlto = 24
    self.margenAbajo = 30
    self.borde = 3

    self.vidaVisible = boss.vida
    self.ultimaVida = boss.vida
    self.retraso = 0.3
    self.tiempoRetraso = 0
    self.velocidadRetraso = 40
end

function Hud:update(dt)

    self.imagenVida = love.graphics.newImage("src/textures/hud/vida.png")
    self.imagenVida:setFilter("linear", "linear")
    self.vidaX = 40
    self.vidaY = 40
    self.espacioVida = 10
    self.tamañoVida = 80

    local vida = self.boss.vida

    if (vida < self.ultimaVida) then
        self.tiempoRetraso = self.retraso
    end
    self.ultimaVida = vida

    if (self.vidaVisible < vida) then
        self.vidaVisible = vida
    end

    if (self.tiempoRetraso > 0) then
        self.tiempoRetraso = self.tiempoRetraso - dt
    elseif (self.vidaVisible > vida) then
        self.vidaVisible = math.max(vida, self.vidaVisible - self.velocidadRetraso * dt)
    end
end

function Hud:draw()
    local ancho = 1920
    local alto = 1080

    local x = (ancho - self.barraAncho) / 2
    local y = alto - self.margenAbajo - self.barraAlto

    local porcentaje = self.boss.vida / self.boss.vidaMax
    local porcentajeVisible = self.vidaVisible / self.boss.vidaMax

    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", x - self.borde, y - self.borde, self.barraAncho + self.borde * 2, self.barraAlto + self.borde * 2)

    love.graphics.setColor(1, 0.6, 0.6)
    love.graphics.rectangle("fill", x, y, self.barraAncho * porcentajeVisible, self.barraAlto)

    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", x, y, self.barraAncho * porcentaje, self.barraAlto)

    love.graphics.setColor(1,1,1)
    love.graphics.print("VENDING MACHINE", x, y - 22)

    love.graphics.setColor(1,1,1,1)

    for i=1, self.character.vida do
        love.graphics.draw(self.imagenVida, self.vidaX + (i - 1) * (self.tamañoVida + self.espacioVida), self.vidaY, 0, self.tamañoVida / self.imagenVida:getWidth(), self.tamañoVida / self.imagenVida:getHeight())
    end
end

return Hud