require 'gosu'
require 'pry'

CELL_SIZE = 16
STAGE_LEFT_WALL = [2,1]
STAGE_SIZE = [15,28]
MAX_STEP_SPEED  = 50
MAX_MOVE_SPEED  = 5
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

class Tetris < Gosu::Window

  def initialize()
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Tetris clone!"
    @block = Block.new(Block::BLOCKS.keys.sample)
    @step_time = 0
    @move_time = 0
    @step_speed = 2
    @move_speed = 2
    @turn = :none
    @move = :none
    @stage = Stage.new(STAGE_SIZE)
    @pause = false
    @ui = UI.new
    @reset = false
    @start_time = Time.new
  end

  def update
    #increse speed every 60 seconds!
    if (Time::now - @start_time) > 60
      @start_time = Time.new
      @step_speed += 1
      puts "Incresed speed!"
    end

    @step_time += 1
    if @step_time > (MAX_STEP_SPEED - @step_speed) or Gosu.button_down? Gosu::KB_DOWN

      if @block.grounded?(@stage)
        @stage.add(@block)
        @block = Block.new(Block::BLOCKS.keys.sample) unless @pause
      end

      @block.step unless @pause
      @step_time = 0
    end

#    @block.rotate_left if @turn == :left
#    @turn = :none
    if @turn == :left && !@pause
      @block.rotate if @block.rotate_possible?(@stage)
    end
    @turn = :none

    @move_time += 1
    if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
      if @move_time > MAX_MOVE_SPEED - @move_speed
        @block.move_left if @block.left_empty?(@stage)
        @move_time = 0
      end
    end

    if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
      if @move_time > MAX_MOVE_SPEED - @move_speed
        @block.move_right if @block.right_empty?(@stage)
        @move_time = 0
      end
    end

    unless @block.inside?(@stage)
      @block.move_inside(@stage)
    end

    if @block.end_game?(@stage)
      @ui.game_over = true
      # @stage.clear
      @pause = true
    end

    @stage.update

    if @reset
      @pause = false
      @stage.clear
      @block = Block.new(Block::BLOCKS.keys.sample)
      @reset = false
      @ui.game_over = false
    end

  end

  def draw
    @block.draw
    @stage.draw
    @ui.draw
  end

  def button_up(id)
    @turn = :left if id == Gosu::KB_UP
    #@pause = true if id == Gosu::KB_SPACE
    @reset = true if id == Gosu::KB_RETURN
    super
  end
end



class UI

  attr_accessor :game_over

  def initialize()
    @img_game_over = Gosu::Image.from_text("GAME OVER!",26)
    @img_background = Gosu::Image.new("stage.bmp",retro:true)
    @game_over = false
  end


  def draw
    if @game_over
    x = ((STAGE_SIZE[0]/2) + STAGE_LEFT_WALL[0])*CELL_SIZE - (@img_game_over.width/2)
    y = ((STAGE_SIZE[1]/2) + STAGE_LEFT_WALL[1])*CELL_SIZE
    @img_game_over.draw(x,y,2)
    end

    #background around stage
    x = SCREEN_WIDTH
    y = STAGE_LEFT_WALL[1]*CELL_SIZE
    @img_background.draw_as_quad(0,0,Gosu::Color::GRAY,
                                 x,0,Gosu::Color::GRAY,
                                 x,y,Gosu::Color::GRAY,
                                 0,y,Gosu::Color::GRAY,2)

    x = SCREEN_WIDTH
    y = (STAGE_SIZE[1]*CELL_SIZE)+CELL_SIZE+2
    @img_background.draw_as_quad(0,y,Gosu::Color::GRAY,
                                 x,y,Gosu::Color::GRAY,
                                 x,SCREEN_HEIGHT,Gosu::Color::GRAY,
                                 0,SCREEN_HEIGHT,Gosu::Color::GRAY,2)

    x = STAGE_LEFT_WALL[0]*CELL_SIZE-2
    y = SCREEN_HEIGHT
    @img_background.draw_as_quad(0,0,Gosu::Color::GRAY,
                                 x,0,Gosu::Color::GRAY,
                                 x,y,Gosu::Color::GRAY,
                                 0,y,Gosu::Color::GRAY,2)

    x = (STAGE_LEFT_WALL[0]+STAGE_SIZE[0])*CELL_SIZE+2
    y = SCREEN_HEIGHT
    @img_background.draw_as_quad(x,0,Gosu::Color::GRAY,
                                 SCREEN_WIDTH,0,Gosu::Color::GRAY,
                                 x,y,Gosu::Color::GRAY,
                                 SCREEN_WIDTH,y,Gosu::Color::GRAY,2)
  end

end


class Cell
  SIZE = 16

  def initialize
  end
end

class Rectangle

  BORDER = 2
  attr_accessor :position :sizeback_color = Gosu::Color::RED
    front_color = Gosu::Color::BLACK
    minx, miny = @min_x*CELL_SIZE, @min_y*CELL_SIZE
    maxx, maxy = @max_x*CELL_SIZE, @max_y*CELL_SIZE
    @image.draw_as_quad(minx-BORDER,miny-BORDER, back_color,
                        maxx+BORDER,miny-BORDER, back_color,
                        maxx+BORDER,maxy+BORDER, back_color,
                        minx-BORDER,maxy+BORDER, back_color, 0)
    @image.draw_as_quad(minx,miny, front_color,
                        maxx,miny, front_color,
                        maxx,maxy, front_color,
                        minx,maxy, front_color, 0)

  def initialize(pos,size)
    @position = position_xy(pos)
    @size = size_xy(size)
  end

  def min_x
    position.x
  end

  def min_y
    position.y
  end

  def max_x
    position.x+size.x
  end

  def max_y
    position.y+size.y
  end

  def draw
    border_color = Gosu::Color::RED
    background_color = Gosu::Color::BLACK
    minx, miny =
    maxx, maxy = @max_x*CELL_SIZE, @max_y*CELL_SIZE
    @image.draw_as_quad(minx-BORDER,miny-BORDER, back_color,
                        maxx+BORDER,miny-BORDER, back_color,
                        maxx+BORDER,maxy+BORDER, back_color,
                        minx-BORDER,maxy+BORDER, back_color, 0)
    @image.draw_as_quad(minx,miny, front_color,
                        maxx,miny, front_color,
                        maxx,maxy, front_color,
                        minx,maxy, front_color, 0)
  end

  private

  def position_xy(pos)
    position = Struct.new(:x, :y)
    position.new(pos[0], pos[1])
  end

  def size_xy(size)
    size = Struct.new(:x, :y)
    size.new(size[0], size[1])
  end

end

class Stage

  BORDER = 2

  attr_reader :min_x, :min_y, :max_x, :max_y, :cells

  def initialize(size)
      @min_x = STAGE_LEFT_WALL[0]
      @min_y = STAGE_LEFT_WALL[1]
      @max_x = @min_x + size[0]
      @max_y = @min_y + size[1]
      @image = Gosu::Image.new("stage.bmp", {tileable:true} )
      @cell_image = Gosu::Image.new("test_cell.bmp")
      @cells = []
  end

  def draw()
    back_color = Gosu::Color::RED
    front_color = Gosu::Color::BLACK
    minx, miny = @min_x*CELL_SIZE, @min_y*CELL_SIZE
    maxx, maxy = @max_x*CELL_SIZE, @max_y*CELL_SIZE
    @image.draw_as_quad(minx-BORDER,miny-BORDER, back_color,
                        maxx+BORDER,miny-BORDER, back_color,
                        maxx+BORDER,maxy+BORDER, back_color,
                        minx-BORDER,maxy+BORDER, back_color, 0)
    @image.draw_as_quad(minx,miny, front_color,
                        maxx,miny, front_color,
                        maxx,maxy, front_color,
                        minx,maxy, front_color, 0)
    # draw cells end
    @cells.each do |cell|
      x = cell[0]*CELL_SIZE
      y = cell[1]*CELL_SIZE
      col = cell[2]

      #@cell_image.draw(cell[0]*CELL_SIZE,cell[1]*CELL_SIZE,1)
      @cell_image.draw_as_quad(x,y,col,
                               x+CELL_SIZE,y,col,
                               x+CELL_SIZE,y+CELL_SIZE,col,
                               x,y+CELL_SIZE,col,1)
    end

  end

  def add(block)
    block.cells.each do |xy|
      @cells << [xy[0]+block.x, xy[1]+block.y, xy[2]]
    end
  end

  def update()
    #@cells.sort_by! { |arr| arr[1] }
    row_max = @max_x - @min_x
    removed = []

    (@min_y..@max_y).each do |index|
      row = @cells.select { |cell| cell[1] == index }
      if row.size == row_max
        @cells.reject! { |cell| cell[1] == index }
        removed << index
      end
    end
    removed.sort!

    @cells.each do |cell|
      removed.each do |row|
        cell[1] = cell[1] + 1 if row > cell[1]
      end
    end
  end

  def clear()
    @cells = []
  end
end


class Block

  GRAY   = 0xff_808080
  AQUA   = 0xff_00ffff
  RED    = 0xff_ff0000
  GREEN  = 0xff_00ff00
  BLUE   = 0xff_0000ff
  YELLOW = 0xff_ffff00
  FUCHSIA= 0xff_ff00ff

  BLOCKS = { I:[[-1,0,0xff_00ffff],[0,0,0xff_00ffff],[1,0,0xff_00ffff],[2,0,0xff_00ffff]],
             J:[[0,0,0xff_ff0000],[-1,0,0xff_ff0000],[-1,-1,0xff_ff0000],[1,0,0xff_ff0000]],
             L:[[0,0,0xff_0000ff],[-1,0,0xff_0000ff],[1,0,0xff_0000ff],[1,-1,0xff_0000ff]],
             O:[[0,0,0xff_ffff00],[1,0,0xff_ffff00],[1,1,0xff_ffff00],[0,1,0xff_ffff00]],
             S:[[0,0,0xff_00ffff],[-1,0,0xff_00ffff],[0,-1,0xff_00ffff],[1,-1,0xff_00ffff]],
             T:[[0,0,0xff_808080],[-1,0,0xff_808080],[1,0,0xff_808080],[0,-1,0xff_808080]],
             Z:[[0,0,0xff_ff00ff],[0,-1,0xff_ff00ff],[-1,-1,0xff_ff00ff],[1,0,0xff_ff00ff]] }




  ROTATION_MATRIX_L = [[0,1],[-1,0]]
  ROTATION_MATRIX_R = [[0,-1],[1,0]]

  attr_reader :x, :y, :cells

  def initialize(shape)
    raise ArgumentError.new("Invalid Shape passed! Shape must \
be one of [:I,:J,:L,:O,:S,:T,:Z]!") unless BLOCKS.keys.include?(shape)
    @shape = shape
    @cell_image = Gosu::Image.new("test_cell.bmp")
    @x = Tetris::STAGE_SIZE[0] / 2 + STAGE_LEFT_WALL[0]
    @y = 0
    @cells = BLOCKS[shape]
    @on_the_block = false
  end

  def rotate_possible?(stage)
    matrix = ROTATION_MATRIX_L
    temp_cells = [[0,0],[0,0],[0,0],[0,0]]
    0.upto(3) do |index|
      new_x = matrix[0][0]*@cells[index][0] + matrix[0][1]*@cells[index][1]
      new_y = matrix[1][0]*@cells[index][0] + matrix[1][1]*@cells[index][1]
      temp_cells[index][0] = new_x
      temp_cells[index][1] = new_y
    end

    0.upto(3) do |index|
      if stage.cells.include?([temp_cells[index][0]+@x,temp_cells[index][1]+@y])
        return false
      end
    end

    temp_cells_y = []
    0.upto(3) do |index|
      temp_cells_y << temp_cells[index][1]
    end
    return false if (temp_cells_y.max + @y) >= stage.max_y-1

    return false if @shape == :O

    return true
  end

  def rotate()
    # ---
    matrix = ROTATION_MATRIX_L
    0.upto(3) do |index|
      new_x = matrix[0][0]*@cells[index][0] + matrix[0][1]*@cells[index][1]
      new_y = matrix[1][0]*@cells[index][0] + matrix[1][1]*@cells[index][1]
      @cells[index][0] = new_x
      @cells[index][1] = new_y
    end
  end

  def move_right()
    @x += 1
  end

  def move_left()
    @x -= 1
  end

  def left_empty?(stage)
    #remove colors

    stage_cells_no_col = stage.cells.map do |cell|
      [cell[0],cell[1]]
    end

    0.upto(3) do |index|
      if stage_cells_no_col.include?([cells[index][0]+@x-1,cells[index][1]+@y])
        return false
      end
    end
    return true
  end

  def right_empty?(stage)

    stage_cells_no_col = stage.cells.map do |cell|
      [cell[0],cell[1]]
    end

    0.upto(3) do |index|
      if stage_cells_no_col.include?([cells[index][0]+@x+1,cells[index][1]+@y])
        return false
      end
    end
    return true
  end

  def offset_right(x)
    @x += x
  end

  def offset_left(x)
    @x -= x
  end

  def min_x()
    cells_x = []
    0.upto(3) do |index|
      cells_x << @cells[index][0]
    end
    cells_x.min + @x
  end

  def max_x()
    cells_x = []
    0.upto(3) do |index|
      cells_x << @cells[index][0]
    end
    cells_x.max + @x
  end

  def min_y()
    cells_y = []
    0.upto(3) do |index|
      cells_y << @cells[index][1]
    end
    cells_y.min + @y
  end

  def max_y()
    cells_y = []
    0.upto(3) do |index|
      cells_y << @cells[index][1]
    end
    cells_y.max + @y
  end

  def inside?(stage)
    if stage.min_x <= self.min_x() and stage.max_x > self.max_x()
      true
    else
      false
    end
  end

  def grounded?(stage)
    @on_the_block = false
    stage_cells_no_col = stage.cells.map do |cell|
      [cell[0],cell[1]]
    end

    0.upto(3) do |index|
      if stage_cells_no_col.include?([cells[index][0]+@x,cells[index][1]+@y+1])
        @on_the_block = true
        return true
      end
      if stage.max_y-1 <= self.max_y()
        return true
      end
    end
    return false
  end

  def end_game?(stage)
    if grounded?(stage) && @on_the_block && self.min_y() <= stage.min_y
      true
    else
      false
    end
  end

  def move_inside(stage)
    if stage.min_x > self.min_x()
      self.offset_right(stage.min_x - self.min_x())
    end
    if stage.max_x <= self.max_x()
      self.offset_left((self.max_x() - stage.max_x) + 1)
    end
  end

  def draw()
    #xy = BLOCKS[@shape]
    0.upto(3) do |index|
      #@cell_image.draw((@cells[index][0]+@x)*CELL_SIZE,
      #(@cells[index][1]+@y)*CELL_SIZE, 1)
      x = (@cells[index][0]+@x)*CELL_SIZE
      y = (@cells[index][1]+@y)*CELL_SIZE
      col = @cells[index][2]
      @cell_image.draw_as_quad(x,y,col,
                               x+CELL_SIZE,y,col,
                               x+CELL_SIZE,y+CELL_SIZE,col,
                               x,y+CELL_SIZE,col,1)
    end
  end

  def step()
    @y += 1
  end
end

Tetris.new.show
