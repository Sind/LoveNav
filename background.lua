background = class()

function background:init()
	self.image = love.graphics.newImage("background.png")
	self.width, self.height = self.image:getDimensions()
end

function background:draw()
	love.graphics.draw(self.image)
end