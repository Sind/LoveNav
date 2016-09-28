MIN_POINT_DISTANCE = 14
POINT_HIT_DISTANCE = MIN_POINT_DISTANCE/2

POINT_RADIUS = 4
LINE_WIDTH = 4

WHITE = {255,255,255}
POINT_COLOR = {0,0,255,200}
TRIANGLE_LINE = {0,200,0,100}
TRIANGLE_FILL = {0,255,0,100}
POINTER_COLOR = {points = {0,0,255,100}, polygon = {0, 255, 0, 100}, delete = {0,0,0,100}}

SCALING_FACTOR = 0.95
function love.load()
	require "class"
	require "point"
	require "triangle"
	require "saveMesh"
	require "persistence"
	mode = "points"
	love.window.setMode(0,0,{fullscreen = true})
	WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
	image = love.graphics.newImage("background.png")
	points = {}
	triangles = {}
	translate = {x=0,y=0}
	scale = 1
	currentPolygon = {}
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
		love.graphics.circle("fill",v[1],v[2],POINT_RADIUS)
	end
	for i,v in ipairs(triangles) do
		v:draw()
	end
	love.graphics.setColor(POINTER_COLOR[mode])
	if mode == "polygon" then
		if #currentPolygon > 0 then
			local line = {}
			for i,v in ipairs(currentPolygon) do
				line[#line+1] = v[1]
				line[#line+1] = v[2]
			end
			line[#line+1] = latestPosition.x
			line[#line+1] = latestPosition.y
			love.graphics.line(line)
		end
	end
	love.graphics.circle("fill",latestPosition.x,latestPosition.y,POINT_RADIUS/scale)
	love.graphics.setColor(WHITE)


end

function love.mousepressed(x,y,button)
	if moving or moving2 then return end
	if button == 3 then
		moving = true
	end
	x = x - translate.x
	y = y - translate.y
	x = x / scale
	y = y / scale
	if button == 1 then
		if mode == "points" then
			if not findPoint(x,y,MIN_POINT_DISTANCE) then
				local p = point:new(x,y)
				points[#points+1] = p
			end
		elseif mode == "delete" then
			local p = findPoint(x,y,POINT_HIT_DISTANCE)
			if p then
				p:remove()
				return
			end
			for i,v in ipairs(triangles) do
				if v:contains(x,y) then
					v:remove()
				end
			end
		elseif mode == "polygon" then
			for i,v in ipairs(points) do
				if dist(v,{[1] = x, [2] = y}) < POINT_HIT_DISTANCE then
					if #currentPolygon > 2 and samePoint(v,currentPolygon[1]) then
						savePolygon()
						currentPolygon = {}
					elseif not containsPoint(currentPolygon,v) then
						currentPolygon[#currentPolygon+1] = v
					end
				end
			end
		end
	end
end


function savePolygon()
	local line = {}
	for i,v in ipairs(currentPolygon) do
		line[#line+1] = v[1]
		line[#line+1] = v[2]
	end
	local ts = love.math.triangulate(line)
	for i,v in ipairs(ts) do
		--one triangle
		local tr = {}
		for i = 1,5,2 do
			local px = v[i]
			local py = v[i+1]
			tr[#tr+1] = findPoint(px,py,POINT_RADIUS)
		end
		local t = triangle:new(tr)
		triangles[#triangles+1] = t
	end

end

function love.wheelmoved(wx,wy)
	zoom(wy)
end

function love.mousemoved(x,y,dx,dy)
	if moving or moving2 then
		translate.x = translate.x + dx
		translate.y = translate.y + dy
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
		saveMesh()
		love.event.quit()
	elseif key == "p" or key == "b" or key == "1" then
		mode = "points"
	elseif key == "4" or key == "g" then
		mode = "polygon"
		currentPolygon = {}
	elseif key == "d" or key == "5" then
		mode = "delete"
	elseif key == "space" then
		moving2 = true
	elseif key == "+" then
		zoom(1)
	elseif key == "-" then
		zoom(-1)
	end
end

function love.keyreleased(key)
	if key == "space" then
		moving2 = false
	end
end

function dist(o1,o2)
	local a = o1[1] - o2[1]
	local b = o1[2] - o2[2]
	return math.sqrt(a*a+b*b)
end

function zoom(direction)
	local x, y = love.mouse.getPosition();
	x = x - translate.x
	y = y - translate.y
	x = x / scale
	y = y / scale
	local oldscale = scale
	scale = scale * math.pow(SCALING_FACTOR, -direction)
	translate.x = translate.x + x * (oldscale - scale)
	translate.y = translate.y + y * (oldscale - scale)
end