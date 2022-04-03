push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'
require 'BrickArray'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

MENU_HEIGHT = 17

PADDLE_SPEED = 200
PADDLE_WIDTH = 40
PADDLE_HEIGHT = 4

BALL_WIDTH = 4
BALL_HEIGHT = 4
BALL_INIT_X = VIRTUAL_WIDTH / 2 - BALL_WIDTH / 2
BALL_INIT_Y = VIRTUAL_HEIGHT / 2.2 - BALL_HEIGHT / 2

-- gameState == 'start' press enter to play
-- gameState == 'serve' press entre to move the ball
-- gameState == 'play' ball moving and all loose ball to stop
-- gameState == 'won' no more brick on the screen option to start again
-- gameState == 'loose' no more lives options to start again
gameState = 'start'

function love.load()
    smallFont = love.graphics.newFont('font.ttf', 8)

    -- initialize our nearest-neighbor filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- app window title
    love.window.setTitle('Brick Breaker')

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
                     {vsync = true, fullscreen = false, resizable = true})
    paddle = Paddle(VIRTUAL_WIDTH / 2 - 10, VIRTUAL_HEIGHT - 20, PADDLE_WIDTH,
                    PADDLE_HEIGHT)
    ball = Ball(BALL_INIT_X, BALL_INIT_Y, BALL_WIDTH, BALL_HEIGHT)
    array = BrickArray()

    score = 0
    lives = 3
end

function love.resize(w, h) push:resize(w, h) end

function love.update(dt)

    if gameState == 'start' then
        ball.speed = -200
        ball.dir = 3 * math.pi / 2
    elseif gameState == 'play' then
        ball:update(dt)
        if ball:collides(paddle) then
            -- moves the ball outside of the colission box
            ball.y = ball.y - PADDLE_HEIGHT

            -- calculate the new direction of the ball
            -- the ball is reflected at a greater angle to the median the closer it is to the edge of the paddle
            -- the refletion angle is in 98% of [-pi ; 0] to avoided too horixontal reflexions
            paddleX = paddle.x + paddle.width / 2
            ballX = (ball.x + ball.width / 2)
            ball.dir = (paddleX - ballX) / paddle.width * 2
            minAngle = 0.15
            ball.dir = math.pi - (ball.dir + 1) * math.pi / 2
            if ball.dir > math.pi / 2 then
                ball.dir = math.min(ball.dir, math.pi - minAngle)
            else
                ball.dir = math.max(ball.dir, minAngle)
            end
        end
        if ball.y < 0 then
            -- the ball reaches the top of the screen
            ball.y = ball.y + ball.height
            ball.dir = 2 * math.pi - ball.dir
        elseif ball.x < 0 then
            -- the ball reaches the left side of the screen
            ball.x = ball.x + ball.width
            ball.dir = math.pi - ball.dir
        elseif ball.x > VIRTUAL_WIDTH then
            ball.x = ball.x - ball.width
            ball.dir = math.pi - ball.dir
        elseif ball.y > VIRTUAL_HEIGHT then
            lives = lives - 1
            ball:reset()
            if lives < 0 then
                gameState = 'loose'
                array:reset()
                ball:reset()
            else
                gameState = 'serve'
            end
        end
        -- keeps ball.dir in [0;2pi] to avoid out of range
        if ball:collidesBricks(array) then
            score = score + 1
            if array:isEmpty() then gameState = 'won' end
        end

        ball.dir = ball.dir % (2 * math.pi)
    end

    if love.keyboard.isDown('left') then
        paddle:update(dt, -PADDLE_SPEED)
    elseif love.keyboard.isDown('right') then
        paddle:update(dt, PADDLE_SPEED)
    else
        paddle:update(dt, 0)
    end
    smallFont = love.graphics.newFont('font.ttf', 8)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
            ball.speed = -150
        elseif gameState == 'loose' or gameState == 'won' then
            gameState = 'start'
            ball:reset()
            array:reset()
            score = 0
            lives = 3
        end
    end
end

function love.draw()
    push:start()
    displayMenu()
    love.graphics.setLineWidth(2)
    love.graphics.line(0, MENU_HEIGHT - 2, VIRTUAL_WIDTH, MENU_HEIGHT - 2)

    if gameState == 'start' then

        love.graphics.printf('Welcome to Brick Breaker!', 0, 120, VIRTUAL_WIDTH,
                             'center')
        love.graphics.printf('Press Enter to begin!', 0, 140, VIRTUAL_WIDTH,
                             'center')
    elseif gameState == 'serve' then

        love.graphics.printf('Press Enter to serve!', 0, 140, VIRTUAL_WIDTH,
                             'center')
    end

    if gameState == 'loose' then
        love.graphics.printf('You ran out of balls', 0, 120, VIRTUAL_WIDTH,
                             'center')
        love.graphics.printf('Press Enter to try again!', 0, 140, VIRTUAL_WIDTH,
                             'center')
    end

    if gameState == 'won' then
        love.graphics.printf('Congratulation you win!', 0, 120, VIRTUAL_WIDTH,
                             'center')
        love.graphics.printf('Press Enter to play again!', 0, 140,
                             VIRTUAL_WIDTH, 'center')
    end

    array:render()
    paddle:render()
    ball:render()
    push:finish()
end

function displayMenu()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    sep = ' | '
    fpsStr = 'FPS: ' .. tostring(love.timer.getFPS()) .. sep
    livesStr = 'Extra balls: ' .. tostring(math.max(lives, 0)) .. sep
    scoreStr = 'Score: ' .. tostring(score) .. sep
    love.graphics.print(fpsStr .. livesStr .. scoreStr .. gameState, 4, 4)
end
