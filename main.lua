MIN_POINT_DISTANCE = 14
POINT_HIT_DISTANCE = MIN_POINT_DISTANCE/2

POINT_RADIUS = 4
LINE_WIDTH = 4

WHITE = {255,255,255}

SCALING_FACTOR = 0.95
function love.load()
	require "class"
	require "mesh/mesh"
	require "background"

	love.window.setMode(0,0,{highdpi = true, fullscreen = true})

	WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
	
	mesh = mesh()

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
	love.graphics.setLineWidth( LINE_WIDTH )

	POINT_RADIUS = POINT_RADIUS * WINDOW_HEIGHT / 1080
end

function love.update()

	x, y = love.mouse.getPosition()

	x = x - screen.translate.x
	y = y - screen.translate.y
	x = x / screen.scale
	y = y / screen.scale

	mesh:update({x=x,y=y})
end

function love.draw()
	love.graphics.translate(screen.translate.x, screen.translate.y)
	love.graphics.scale(screen.scale)
	background:draw()
	mesh:draw(screen.scale)
end

function love.mousepressed(x,y,button)
	if moving or moving2 then return end
	if button == 3 then
		moving = true
	end
	x = x - screen.translate.x
	y = y - screen.translate.y
	x = x / screen.scale
	y = y / screen.scale
	mesh:mousepressed(x,y,button)
end


function love.wheelmoved(wx,wy)
	zoom(wy)
end

function love.mousemoved(x,y,dx,dy)
	if moving or moving2 then
		screen.translate.x = screen.translate.x + dx
		screen.translate.y = screen.translate.y + dy
	end
end
function love.mousereleased(x,y,button)
	if button == 3 then
		moving = false
	end
end

function love.keypressed(key)
	if moving or moving2 then return end
	if key == "escape" then
		mesh:save()
		love.event.quit()
	elseif key == "space" then
		moving2 = true
	elseif key == "+" then
		zoom(1)
	elseif key == "-" then
		zoom(-1)
	else
		mesh:keypressed(key)
	end
end

function love.keyreleased(key)
	if key == "space" then
		moving2 = false
	end
end


function zoom(direction)
	local x, y = love.mouse.getPosition();
	x = x - screen.translate.x
	y = y - screen.translate.y
	x = x / screen.scale
	y = y / screen.scale
	local oldscale = screen.scale
	screen.scale = screen.scale * math.pow(SCALING_FACTOR, -direction)
	screen.translate.x = screen.translate.x + x * (oldscale - screen.scale)
	screen.translate.y = screen.translate.y + y * (oldscale - screen.scale)
end