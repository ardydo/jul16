local composer = require( "composer" )
local physics = require( "physics" )
physics.start()

local scene = composer.newScene()
local sceneGroup = 0
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function newBox( x, y )
    local crate = display.newImage( "crate.png", x, y )
    physics.addBody( crate, { density=3.0, friction=0.5, bounce=0.3 } )
    crate.rotation = math.random(360)
    sceneGroup:insert( crate )
end

function screenTap( event )
    local x = event.x
    local y = event.y
    newBox(x, y)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    newBox(50, 50)

    local sky = display.newImage( "bkg_clouds.png", 160, 195 )

    local ground = display.newImage( "ground.png", 160, 445 )

    physics.addBody( ground, "static", { friction=0.5, bounce=0.3 } )

    sceneGroup:insert( sky )
    sceneGroup:insert( ground )

end

-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

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

display.currentStage:addEventListener("tap",  screenTap)


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene