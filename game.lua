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
local alive
local score = 0
local scoreDisplay
local spawnTimerDefault = 60 * 1
local spawnTimer = spawnTimerDefault

local function touchReset ( )
    leftTouch = false
    rightTouch = false

end

local function screenTouch( event )
    local x = event.x
    local y = event.y
    
    -- alive filter
    if alive then
        
        -- phase filter
        if event.phase == "began" then
            
            -- touched to the right
            if (x > display.contentCenterX ) then
                rightTouch = true
            
            -- touched to the left
            elseif ( x <= display.contentCenterX ) then
                leftTouch = true
            end
        
        -- reset vars to stop code from running
        elseif event.phase == "ended" then
            touchReset( )
        
        end 
    
    end

end

local function spawnEnemy( x )
    --if alive then
        -- local copy of the scene group
        local sceneGroup = scene.view
        -- setting the y offscreen
        local y = screenHeight * -0.1 
        -- enemy image
        local enemy = display.newImage( "enemy.png", x, y )
        sceneGroup:insert( enemy )
        -- circular body
        physics.addBody( enemy, "dynamic", {radius = 13} )
        -- to not really collide with the player
        enemy.isSensor = true
        -- the name for collision purposes
        enemy.name = "enemy"
        local enemySpin = 50
        enemy.angularVelocity = ( math.random( -enemySpin, enemySpin ) )

    --end

end

-- player initialization
local function playerInit( )
    -- player image
    player = display.newImage("ship.png", screenWidth * 0.5, screenHeight * 0.8 )

    -- player collision mask
    local mask = { -2, -26, 2, -26, 22, 25, -22, 25}
    physics.addBody( player , { shape = mask})
    -- nullifying gravity
    player.gravityScale = 0
    -- setting the y-axis lock
    player.lock = screenHeight * 0.8
    -- aceleration per step
    player.acel = 1
    -- setting the alive var
    alive = true

    local function spawner(  )
        -- run the timer
        spawnTimer = spawnTimer - 1

        -- trigger the timer
        if spawnTimer <= 0 then
            print("here it comes!" )
            -- setting a random x to spawn the enemy
            local x = math.random( screenWidth * 0.1, screenWidth * 0.9 )
            
            -- spawn the enemy
            spawnEnemy( x )

            -- adjust the time
            if spawnTimerDefault > 20 then
                spawnTimerDefault = spawnTimerDefault - 5

            elseif spawnTimerDefault > 10 then
                spawnTimerDefault = spawnTimerDefault - 1

            end

            print(spawnTimerDefault)

            -- reset the timer
            spawnTimer = spawnTimerDefault
        
        end

    end



    -- player step function
    function player.enterFrame ( self )
        local acel = self.acel
        local x = self.x
        local y = self.y
        -- lock the y-axis
        self.y = self.lock
        
        -- alive filter
        if alive then

            spawner( )

            -- right thrust
            if rightTouch then
                self:applyForce( acel, 0, x, y )

            -- left thrust
            elseif leftTouch then
                self:applyForce( -acel, 0, x, y )

            end
        
        end
    
    end

    -- player - enemy collision
    local function collision( self, event )
        -- gettint the name
        local target = event.other.name

        if (event.phase == "began") then
            
            -- name filter
            if ( target == "enemy" ) then
                -- u ded
                alive = false
                -- take yourself to the graveyard
                self:removeSelf( )
                composer.removeScene( "gameover" )
                composer.showOverlay( "gameover", { time = 500, effect = "crossFade" } )

            end

        end
    
    end

    player.collision = collision
    player:addEventListener( "collision")
    Runtime:addEventListener( "enterFrame", player )

end

local function remover( )
    -- local copy of the view
    local sceneGroup = scene.view
    -- a rect offscreen and of it's same width
    local me = display.newRect( screenWidth * 0.5, screenHeight * 1.1, screenWidth, 20 )
    sceneGroup:insert ( me )
    -- static body so it doesn't fall away
    physics.addBody( me, "static" )
    -- name for collision purpose
    name = "remover"
    me.isSensor = true

    local function collision ( self, event, other )
        local target = event.other.name
        if (event.phase == "began") then
            
            if (target == "enemy") then
                -- add score if the player is alice
                
                if alive then
                    score = score + 10
                    currentScoreDisplay.text = string.format ( score )
                
                end
                
                -- destroy the enemy
                event.other:removeSelf( )
                event.other = nil
            
            end
        
        end
    
    end
    
    me.collision = collision
    me:addEventListener("collision")

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
    local background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight + 20)
    background:setFillColor( 149/255, 199/255, 236/255 )
    sceneGroup:insert(background)

    --middle mark
    --to show what side to press to launch the ship
    local mark = display.newLine( display.contentCenterX, screenHeight * 0.05, display.contentCenterX, screenHeight * 0.95 )
    mark:setStrokeColor( 36/255, 100/255, 145/255, 60/255 )
    sceneGroup:insert(mark)

    -- the player
    playerInit( )
    sceneGroup:insert( player )

    -- the remover
    remover( )
    
    -- barrier sizes
    local barrierW = 10
    local barrierH = screenHeight + 20
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

    -- score
    local options = {
        text = "0",
        x = screenWidth * 0.5,
        y = 10,
        width = screenWidth,
        fontSize = 16,
        align = "center",
    }
    currentScoreDisplay = display.newText( options )
    sceneGroup:insert( currentScoreDisplay )

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        score = 0
        currentScoreDisplay.text = score
        

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        -- Go ´phshsyhsucs
        spawnEnemy( screenWidth * 0.5 )
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