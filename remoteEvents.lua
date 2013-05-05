local centerX, centerY, screenX, screenY = display.contentWidth*.5, display.contentHeight*.5, display.screenOriginX, display.screenOriginY
local screenWidth, screenHeight = display.contentWidth-2*screenX, display.contentHeight-2*screenY
display.tl, display.tc, display.tr = display.TopLeftReferencePoint, display.TopCenterReferencePoint, display.TopRightReferencePoint
display.cl, display.c,  display.cr = display.CenterLeftReferencePoint, display.CenterReferencePoint, display.CenterRightReferencePoint
display.bl, display.bc, display.br = display.BottomLeftReferencePoint, display.BottomCenterReferencePoint, display.BottomRightReferencePoint

local socket = require( "socket" )

local function newConsole( params )
	local fontSize = params.fontSize or 5
	local width = params.width or 128
	local height = params.height or 72
	local g = display.newGroup()

	local back = display.newRect( 0, 0, width, height )
	back:setReferencePoint( display.tl )
	back.x, back.y = -1, -1
	back.strokeWidth = 1
	back:setFillColor( 0, 0, 0, 225 )
	back:setStrokeColor( 255, 255, 255, 225 )
	g:insert( back )

	local lines = {}
	local maxLines = 10
	local tmp = display.newText( "Tjf", 0, 0, native.systemFont, fontSize )
	local lineHeight = tmp.contentHeight
	tmp:removeSelf()
	
	function g:print( str )
		local line = display.newText( str, 0, 0, native.systemFont, fontSize )
		line:setReferencePoint( display.tl )
		line.x, line.y = 2, lineHeight * #lines
		g:insert( line )
		lines[#lines+1] = line
		while g.contentHeight > back.contentHeight do
			lines[1]:removeSelf()
			for i=2, maxLines do
				lines[i-1] = lines[i]
				lines[i-1]:translate( 0, - lineHeight )
			end
			lines[#lines] = nil
		end
	end
	
	return g
end
local console = newConsole( { width=128, height=72, fontSize=5 } )
console:setReferencePoint( display.tr )
console.x, console.y = screenX+screenWidth, screenY

local function startServer()
	local socket = require("socket")
 
	local client = socket.connect("www.google.com",  80)
	local ip = client:getsockname()
 	local port = 6417

	local server = assert( socket.bind( "*", port ) )
	server:settimeout( 0 )
	console:print( "Listening on IP "..ip..", Port " .. port )

	local manageClient, initClient

	manageClient = function( client )
		local loop
		local function stopClient()
			Runtime:removeEventListener( "enterFrame", loop )
			client:close()
			initClient()
		end

		loop = function( event )
			local line, err = client:receive()
			-- if there was no error, send it back to the client
			if not err then
				if line == "stop" then
					stopClient()
				else
					local pairs = string.split( line, "," )
					local event = {}
					console:print( "RECEIVED EVENT:" )
					for i = 1, #pairs do
						local pair = pairs[i]
						local type = string.sub( pair, 1, 1)
						local values = string.split( string.sub( pair, 2 ), "=" )
						if type == "I" then
							values[2] = tonumber( values[2] )
						elseif type == "B" then
							values[2] = values[2]=="true" or false
						end
						event[values[1]] = values[2]
						console:print( tostring(values[1]).."="..tostring(values[2]) )
					end
					Runtime:dispatchEvent( event )
				end	
			elseif err ~= "timeout" then
				stopClient()
				if err == "closed" then
					console:print( "Client disconnected" )
				else
					console:print( "Network Error: "..err )
				end
			end
			console:toFront()
		end
		Runtime:addEventListener( "enterFrame", loop )
	end
	
	initClient = function()
		local function connectLoop( event )
			local recv, send, err = socket.select( { server }, nil, 0 )
			if not err and recv and #recv > 0 then
				console:print( "Client connected")
				Runtime:removeEventListener( "enterFrame", connectLoop )
				local client = server:accept()
				client:settimeout( 0 )
				manageClient( client )
			end
			console:toFront()
		end
		Runtime:addEventListener( "enterFrame", connectLoop )
	end
	
	initClient()
end

timer.performWithDelay( 500, startServer )
