ALLOWED_DISTANCE = 7
POINT_RADIUS = 4
LINE_WIDTH = 4
WHITE = {255,255,255}
POINT_COLOR = {0,0,255,200}
TRIANGLE_LINE = {green = {0,200,0,100}, red = {200,0,0,100}}
TRIANGLE_FILL = {green = {0,255,0,100}, red = {255,0,0,100}}
POINTER_COLOR = {points = {0,0,255,100}, green = {0,255,0,100},red = {255,0,0,100}}
function love.load()
	love.window.setMode(0,0,{fullscreen = true})
	WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDimensions()
	require "class"
	image = love.graphics.newImage("background.png")
	require "point"
	require "triangle"
	mode = "points"
	points = {}
	triangles = {}
	translate = {x=0,y=0}
	scale = 1
	currentTriangle ={}
	love.graphics.setLineWidth( LINE_WIDTH )
	latestPosition = {x=0,y=0}
end

function love.update()
	x, y = love.mouse.getPosition()

	x = x - translate.x
	y = y - translate.y
	x = x / scale
	y = y / scale

	latestPosition = {x=x,y=y}
end

function love.draw()
	love.graphics.translate(translate.x, translate.y)
	love.graphics.scale(scale)
	love.graphics.draw(image)
	love.graphics.setColor(POINT_COLOR)
	for i,v in ipairs(points) do
		love.graphics.circle("fill",v.x,v.y,POINT_RADIUS)
	end
	for i,v in ipairs(triangles) do
		v:draw()
	end
	love.graphics.setColor(POINTER_COLOR[mode])
	love.graphics.circle("fill",latestPosition.x,latestPosition.y,POINT_RADIUS/scale)
	love.graphics.setColor(WHITE)


end

function love.mousepressed(x,y,button)
	if moving then return end
	if button == "m" then
		moving = true
	end
	x = x - translate.x
	y = y - translate.y
	x = x / scale
	y = y / scale
	if button == "wd" then
		scale = scale - 0.1
		translate.x = translate.x + x * 0.1
		translate.y = translate.y + y * 0.1
	elseif button == "wu" then
		scale = scale + 0.1
		translate.x = translate.x - x * 0.1
		translate.y = translate.y - y * 0.1
	end
	if button == "l" then
		if mode == "points" then
			local p = point:new(#points+1,x,y)
			points[#points+1] = p
		elseif mode == "green" or mode == "red" then
			for i,v in ipairs(points) do
				if dist(v,{x=x,y=y}) < ALLOWED_DISTANCE then
						currentTriangle[#currentTriangle+1] = v
					if #currentTriangle == 3 then
						local t = triangle:new(#triangles+1,mode,currentTriangle)
						triangles[#triangles+1] = t
						if mode == "green" then
							currentTriangle[1]:addNeighbor(currentTriangle[2])
							currentTriangle[1]:addNeighbor(currentTriangle[3])
							currentTriangle[2]:addNeighbor(currentTriangle[1])
							currentTriangle[2]:addNeighbor(currentTriangle[3])
							currentTriangle[3]:addNeighbor(currentTriangle[1])
							currentTriangle[3]:addNeighbor(currentTriangle[2])
						end
						currentTriangle = {}
					end
				end
			end
		end
	end
end
function love.mousemoved(x,y,dx,dy)
	if moving then
		translate.x = translate.x + dx
		translate.y = translate.y + dy
	end
end
function love.mousereleased(x,y,button)
	if button == "m" then
		moving = false
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "p" or key == "1" then
		mode = "points"
	elseif key == "g" or key == "2" then
		mode = "green"
	elseif key == "r" or key == "3" then
		mode = "red"
	end
end

function dist(o1,o2)
	local a = o1.x - o2.x
	local b = o1.y - o2.y
	return math.sqrt(a*a+b*b)
end
