local composer = require( "composer" )
local scene = composer.newScene()

local physics = require( "physics" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- starting the player because scope
local player
-- width and thingies cuz scop
local screenWidth = display.contentWidth
local screenHeight = display.contentHeight
local leftTouch = false
local rightTouch = false

local function touchReset ( )
    leftTouch = false
    rightTouch = false
end

local function screenTouch( event )
    local x = event.x
    local y = event.y

    -- print("boop")
    if event.phase == "began" then
        if (x > player.x ) then
            rightTouch = true
        elseif ( x <= player.x ) then
            leftTouch = true
        end
    end
    
    if (event.phase == "ended") then
        touchReset( )
    end
end

-- player initialization
local function playerInit( )
    player = display.newImage("ship.png", screenWidth * 0.5, screenHeight * 0.8 )
    local mask = { -2, -26, 2, -26, 22, 25, -22, 25}
    physics.addBody( player , { shape = mask})
    player.gravityScale = 0
    player.lock = screenHeight * 0.8
    player.acel = 1

    function player.enterFrame ( self )
        local acel = self.acel
        local x = self.x
        local y = self.y
        -- y-axis lock
        self.y = self.lock
        
        if rightTouch then
            self:applyForce( acel, 0, x, y )
        elseif leftTouch then
            self:applyForce( -acel, 0, x, y )
        end
    end

    Runtime:addEventListener( "enterFrame", player )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    physics.start( )
    --physics.setDrawMode( "hybrid" )
    physics.pause( )

    -- background
    local background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    background:setFillColor( 149/255, 199/255, 236/255 )
    sceneGroup:insert(background)

    --middle mark
    --to show what side to press to launch the ship
    --[[
    local mark = display.newLine( display.contentCenterX, screenHeight * 0.05, display.contentCenterX, screenHeight * 0.95 )
    mark:setStrokeColor( 36/255, 100/255, 145/255, 60/255 )
    sceneGroup:insert(mark)
    --]]

    -- the player
    playerInit( )
    sceneGroup:insert( player )
    
    -- barrier sizes
    local barrierW = 10
    local barrierH = screenHeight
    local barrierX = barrierW * 0.5
    local barrierY = barrierH * 0.5
    local barrierColor = { 36/255, 100/255, 145/255, 1 }
    -- left barrier
    local leftB = display.newRect( barrierX, barrierY, barrierW, barrierH )
    leftB:setFillColor( unpack(barrierColor) )
    sceneGroup:insert( leftB )
    physics.addBody( leftB, "static" )
    -- right barrier
    local rightB = display.newRect( screenWidth - barrierX, barrierY, barrierW, barrierH )
    rightB:setFillColor( unpack(barrierColor) )
    sceneGroup:insert( rightB )
    physics.addBody( rightB, "static" )

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        -- Go ´phshsyhsucs
        physics.start( )

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        physics.stop( )

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

display.currentStage:addEventListener( "touch", screenTouch )

return scene