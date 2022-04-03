Ball = Class {}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.speed = 0
    -- diretion of the ball in radian, self.dir == 3math.pi/2 the balls goes straight down
    self.dir = 0

    -- stores the cooridnates of the previous cell visited by the ball
    -- used to detemine the direction of the collision with a brick
    self.prevI = 0
    self.prevJ = 0
end

function Ball:update(dt)
    self.x = self.x + math.cos(self.dir) * self.speed * dt
    self.y = self.y + math.sin(self.dir) * self.speed * dt
end

function Ball:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end
    return true
end

function Ball:collidesBricks(array)
    ret = false
    local i = math.floor((self.y - MENU_HEIGHT) / 14)
    local j = math.floor(self.x / 24)
    if type(array.bricks[i]) == 'table' and array.bricks[i][j] then
        array.bricks[i][j] = false
        array.brickNumb = array.brickNumb - 1
        ret = true
        if i ~= self.prevI then
            self.dir = 2 * math.pi - self.dir
        elseif j ~= self.prevJ then
            self.dir = math.pi - self.dir
        end
    end
    self.prevI = i
    self.prevJ = j
    return ret
end

function Ball:reset()
    self.x = BALL_INIT_X
    self.y = BALL_INIT_Y
    self.speed = 0
    self.dir = 3 * math.pi / 2
    self.prevI = 0
    self.prevJ = 0
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
