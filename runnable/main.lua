
function love.load()
	require "class"
	require "navmesh"
	level = require "level"
	n = navmesh:new(level)
	background = love.graphics.newImage("background.png")
	previousPoint = {x = 0, y = 0}
	currentPoint = {x = 0, y = 0}
	-- a = navmesh.getAngle({0,0},{0,50},{50,0})
	-- print(a)
end

function love.update(dt)

end


function drawportals(portals)
	love.graphics.setColor(0, 0, 255, 255)
	for i = 4, #portals-2,2 do
		-- print("drawing line",portals[i-1][1],  portals[i-1][2],portals[i][1],  portals[i][2])
		love.graphics.line(portals[i-1][1],  portals[i-1][2],portals[i][1],  portals[i][2]);
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function love.mousepressed(x,y)
	previousPoint = currentPoint
	local x, y = love.mouse.getPosition()
	currentPoint = {x = x, y = y}
	portals, tpath = n:findPath(previousPoint.x,previousPoint.y,currentPoint.x,currentPoint.y)
	if portals == nil then return end
	for i,v in ipairs(portals) do
		print (v[1],v[2])
	end
	print()
end
function love.draw()
	love.graphics.draw(background)
	n:draw()
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.circle("fill",previousPoint.x , previousPoint.y, 2)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.circle("fill",currentPoint.x , currentPoint.y, 2)
	love.graphics.setColor(255, 255, 255, 255)
	if portals == nil then return end
	-- print("drawing portals")
	drawportals(portals)
	if tpath then tpath:draw() end
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
end