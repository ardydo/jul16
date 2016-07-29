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


local function screenTouch( event )
    local x = event.x
    local y = event.y
    local force = 2

    -- print("boop")
    if (x > screenWidth * 0.5 ) then
        player:applyForce( force, 0, player.x, player.y )
        player:applyTorque( force )

    elseif ( x <= screenWidth ) then
        player:applyForce( -force, 0, player.x, player.y )
        player:applyTorque( -force )
        
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    physics.start( )
    physics.pause( )
    
    -- the player
    player = display.newImage( sceneGroup, "ship.png", screenWidth * 0.5, screenHeight * 0.8 )
    physics.addBody( player )
    player.gravityScale = 0
    sceneGroup:insert( player )
    
    -- barrier sizes
    local barrierW = 10
    local barrierH = screenHeight
    local barrierX = barrierW * 0.5
    local barrierY = barrierH * 0.5
    -- left barrier
    local leftB = display.newRect( barrierX, barrierY, barrierW, barrierH )
    leftB:setFillColor( 0, 1, 0 )
    sceneGroup:insert( leftB )
    physics.addBody( leftB, "static" )
    -- right barrier
    local rightB = display.newRect( screenWidth - barrierX, barrierY, -barrierW, barrierH )
    rightB:setFillColor( 0, 1, 0 )
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