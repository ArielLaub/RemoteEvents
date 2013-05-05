display.setStatusBar( display.HiddenStatusBar )
system.activate( "multitouch" )

local centerX, centerY, screenX, screenY = display.contentWidth*.5, display.contentHeight*.5, display.screenOriginX, display.screenOriginY
local screenWidth, screenHeight = display.contentWidth-2*screenX, display.contentHeight-2*screenY
display.tl, display.tc, display.tr = display.TopLeftReferencePoint, display.TopCenterReferencePoint, display.TopRightReferencePoint
display.cl, display.c,  display.cr = display.CenterLeftReferencePoint, display.CenterReferencePoint, display.CenterRightReferencePoint
display.bl, display.bc, display.br = display.BottomLeftReferencePoint, display.BottomCenterReferencePoint, display.BottomRightReferencePoint


local socket = require( "socket" )
local widget = require( "widget" )
local client, onAccelerate, message, connectBtn
local host, port = "localhost", 6417


local messageRect = display.newRect( 0, 0, screenWidth, 20 )
messageRect:setFillColor( 64, 64, 64 )
messageRect.x, messageRect.y = centerX, screenY+screenHeight-messageRect.height*.5
local message = display.newText( "Welcome!", 0, 0, native.systemFontBold, 16 )
message:setReferencePoint( display.cl )
message.x, message.y = 5, messageRect.y

local xGravityLabel = display.newText( "", 0, 0, native.systemFont, 24 )
local yGravityLabel = display.newText( "", 0, 0, native.systemFont, 24 )
local zGravityLabel = display.newText( "", 0, 0, native.systemFont, 24 )
local xInstantLabel = display.newText( "", 0, 0, native.systemFont, 24 )
local yInstantLabel = display.newText( "", 0, 0, native.systemFont, 24 )
local zInstantLabel = display.newText( "", 0, 0, native.systemFont, 24 )
local isShakeLabel = display.newText( "", 0, 0, native.systemFont, 24 )
local function setLabels( params )
	local params = params or {}
	xGravityLabel.text = "xGravity:\t"..string.sub( tostring( params.xGravity or "N/A" ), 1, 5 )
	yGravityLabel.text = "yGravity:\t"..string.sub( tostring( params.yGravity or "N/A" ), 1, 5 )
	zGravityLabel.text = "zGravity:\t"..string.sub( tostring( params.zGravity or "N/A" ), 1, 5 )
	xInstantLabel.text = "xInstant:\t"..string.sub( tostring( params.xInstant or "N/A" ), 1, 5 )
	yInstantLabel.text = "yInstant:\t"..string.sub( tostring( params.yInstant or "N/A" ), 1, 5 )
	zInstantLabel.text = "zInstant:\t"..string.sub( tostring( params.zInstant or "N/A" ), 1, 5 )
	isShakeLabel.text =  "isShake: \t"..tostring( params.isShake or "N/A" )
	xGravityLabel:setReferencePoint( display.cl )
	yGravityLabel:setReferencePoint( display.cl )
	zGravityLabel:setReferencePoint( display.cl )
	xInstantLabel:setReferencePoint( display.cl )
	yInstantLabel:setReferencePoint( display.cl )
	zInstantLabel:setReferencePoint( display.cl )
	isShakeLabel:setReferencePoint( display.cl )
	xGravityLabel.x, xGravityLabel.y = screenX+10, screenY+130
	yGravityLabel.x, yGravityLabel.y = screenX+10, screenY+160
	zGravityLabel.x, zGravityLabel.y = screenX+10, screenY+190
	xInstantLabel.x, xInstantLabel.y = screenX+10, screenY+220
	yInstantLabel.x, yInstantLabel.y = screenX+10, screenY+250
	zInstantLabel.x, zInstantLabel.y = screenX+10, screenY+280
	isShakeLabel.x, isShakeLabel.y = screenX+10, screenY+310
end
setLabels()

local function setMessage( msg, isError )
	message.text = msg
	if isError then
		messageRect:setFillColor( 255, 64, 64 )
	else
		messageRect:setFillColor( 64, 255, 64 )
	end
	message:setReferencePoint( display.cl )
	message.x, message.y = 5, messageRect.y
end

local connected = false
local function disconnect()
	if client then
		setMessage( "Disconnected", true )
		client:close()
		client = nil
		connected = false
		connectBtn:setLabel( "Connect" )
	end
end

onAccelerate = function( event )
	if client then
		local msg = "Sname="..event.name
		msg = msg .. ",IxGravity="..event.xGravity
		msg = msg .. ",IyGravity="..event.yGravity
		msg = msg .. ",IzGravity="..event.zGravity
		msg = msg .. ",IxInstant="..event.xInstant
		msg = msg .. ",IyInstant="..event.yInstant
		msg = msg .. ",IzInstant="..event.zInstant
		msg = msg .. ",BisShake="..tostring( event.isShake ).."\n"
		local sent, err = client:send( msg )
		if not sent and err then
			Runtime:removeEventListener( "acceleraometer", onAccelerate )
			disconnect()
		else
			setLabels( event )
		end
	end
end

local function connect()
	setMessage( "connecting..." )
	client = assert( socket.tcp() )
	client:settimeout( 5 )
	local r, err = client:connect( host, port )
	if r == 1 then
		setMessage( "connected" )
		Runtime:addEventListener ( "accelerometer", onAccelerate )
		connected = true
		connectBtn:setLabel( "Disconnect" )
	else
		disconnect()
		setMessage( "not connected: "..tostring(err), true )
	end
	
	return connected
end

local function connectClick( event )
	if connected then
		disconnect()
	else
		connect()
	end
end

connectBtn = widget.newButton( {
	label = "Connect",
	width = 150,
	height = 40,
	onRelease = connectClick
})
connectBtn:setReferencePoint( display.cl )
connectBtn.x, connectBtn.y = screenX+200, screenY+65

local hostLabel = display.newText( "Host:", 0, 0, native.systemFontBold, 24 )
hostLabel:setReferencePoint( display.cl )
hostLabel.x, hostLabel.y = screenX+10, screenY+25
local hostField
local function textListener( event )
	if event.phase == "ended" or event.phase == "submitted" then
		ip = hostField.text
	end
end
-- Create our Text Field
hostField = native.newTextField( screenX+10, screenY+50, 180, 30 )
hostField.userInput = textListener
hostField:addEventListener( "userInput", hostField )
hostField.text = host
hostField.size = 18
