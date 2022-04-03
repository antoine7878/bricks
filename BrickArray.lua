BrickArray = Class {}

function BrickArray:init()
    self.width = 18
    self.height = 5
    self.brickWidth = 20
    self.brickHeight = 10
    self.space = 2
    self.bricks = {}
    self.brickNumb = self.width * self.height
    self.BRICK_NUMB_INIT = self.brickNumb

    for i = 0, self.height do
        self.bricks[i] = {}
        for j = 0, self.width do self.bricks[i][j] = true end
    end
end

function BrickArray:render()
    for i = 0, self.height do
        for j = 0, self.width do
            if self.bricks[i][j] == true then
                love.graphics.rectangle('fill', j *
                                            (self.brickWidth + self.space * 2) +
                                            self.space, i *
                                            (self.brickHeight + self.space * 2) +
                                            self.space + MENU_HEIGHT,
                                        self.brickWidth, self.brickHeight)
            end
        end
    end
end

function BrickArray:isEmpty()
    for i = 0, self.height do
        for j = 0, self.width do
            if self.bricks[i][j] then return false end
        end
    end
    return true
end

function BrickArray:reset()
    self.bricks = {}
    for i = 0, self.height do
        self.bricks[i] = {}
        for j = 0, self.width do self.bricks[i][j] = true end
    end
    self.brickNumb = self.width * self.height
end
