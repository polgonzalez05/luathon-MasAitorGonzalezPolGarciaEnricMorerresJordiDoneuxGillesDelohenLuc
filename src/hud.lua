local Object = Object or require "lib/classic"

local Hud = Object:extend()

function Hud:new(boss, character)
    self.font = love.graphics.newFont("src/fonts/Minecraft.ttf")
    self.imagenVida = love.graphics.newImage("src/textures/hud/vida.png")
    self.imagenVida:setFilter("linear", "linear")

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

    self.vidaX = 40
    self.vidaY = 40
    self.espacioVida = 10
    self.tamañoVida = 80
end

function Hud:update(dt)
    local vida = self.boss.vida

    if (vida < self.ultimaVida) then
        self.tiempoRetraso = self.retraso
    end

    self.ultimaVida = vida

    if (self.vidaVisible < vida) then
        self.vidaVisible = vida
    end

    if (self.tiempoRetraso > 0) then
        self.tiempoRetraso = math.max(0, self.tiempoRetraso - dt)
    elseif (self.vidaVisible > vida) then
        self.vidaVisible = math.max(vida, self.vidaVisible - self.velocidadRetraso * dt)
    end
end

function Hud:draw()
    local x = (1920 - self.barraAncho) / 2
    local y = 1080 - self.margenAbajo - self.barraAlto

    local porcentaje = self.boss.vida / self.boss.vidaMax
    local porcentajeVisible = self.vidaVisible / self.boss.vidaMax

    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", x - self.borde, y - self.borde, self.barraAncho + self.borde * 2, self.barraAlto + self.borde * 2)

    love.graphics.setColor(1, 0.6, 0.6)
    love.graphics.rectangle("fill", x, y, self.barraAncho * porcentajeVisible, self.barraAlto)

    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", x, y, self.barraAncho * porcentaje, self.barraAlto)

    love.graphics.setFont(self.font)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("VENDING MACHINE", x, y - 22)

    local escala = self.tamañoVida / self.imagenVida:getWidth()

    for i=1, self.character.vida do
        love.graphics.draw(self.imagenVida, self.vidaX + (i - 1) * (self.tamañoVida + self.espacioVida), self.vidaY, 0, escala, escala)
    end

    love.graphics.setColor(1,1,1,1)
end

return Hud