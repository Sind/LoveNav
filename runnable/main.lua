
function love.load()
	require "class"
	require "navmesh"
	level = require "level1"
	n = navmesh:new(level)
	background = love.graphics.newImage("background.png")
	previousPoint = {x = 0, y = 0}
	currentPoint = {x = 0, y = 0}
end

function love.update(dt)

end

function love.mousepressed(x,y)
	previousPoint = currentPoint
	local x, y = love.mouse.getPosition()
	currentPoint = {x = x, y = y}
	cPath = n:findPath(previousPoint.x,previousPoint.y,currentPoint.x,currentPoint.y)
end
function love.draw()
	love.graphics.draw(background)
	n:draw()	
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
end