
function love.load()
	require "class"
	require "navmesh"
	require "background"
	level = require "level"
	n = navmesh:new(level)
	previousPoint = {x = 0, y = 0}
	currentPoint = {x = 0, y = 0}
	
	love.window.setMode(0,0,{highdpi = true, fullscreen = true})

	WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
	

	background = background("background.png")
	
	screen = {}
	screen.translate = {x=0,y=0}

	local imagewider = WINDOW_HEIGHT / background.height > WINDOW_WIDTH / background.width
	if imagewider then
		screen.scale = WINDOW_WIDTH / background.width
		screen.translate.y = (WINDOW_HEIGHT - background.height * screen.scale) / 2
	else
		screen.scale = WINDOW_HEIGHT / background.height
		screen.translate.x = (WINDOW_WIDTH - background.width * screen.scale) / 2
	end
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

	x = x - screen.translate.x
	y = y - screen.translate.y
	x = x / screen.scale
	y = y / screen.scale
	
	previousPoint = currentPoint
	currentPoint = {x = x, y = y}
	portals, tpath = n:findPath(previousPoint.x,previousPoint.y,currentPoint.x,currentPoint.y)
	if portals == nil then return end
	for i,v in ipairs(portals) do
		print (v[1],v[2])
	end
	print()
end

function love.draw()
	love.graphics.translate(screen.translate.x, screen.translate.y)
	love.graphics.scale(screen.scale)

	background:draw()
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