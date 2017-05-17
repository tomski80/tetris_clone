require 'gosu'
require 'pry'

class Tetris < Gosu::Window

  SHAPES = [:I, :J, :L, :O, :S, :T, :Z]
  STAGE_SIZE = [15,28]
  MAX_STEP_SPEED  = 50
  MAX_MOVE_SPEED  = 5
  SCREEN_WIDTH = 640
  SCREEN_HEIGHT = 480

  def initialize()
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Tetris clone!"

    @block = Block.new(SHAPES.sample)
    @step_time = 0
    @move_time = 0
    @step_speed = 2
    @move_speed = 2
    @turn = false
    @move = :none
    @stage = Stage.new(STAGE_SIZE)
    @pause = false
    @ui = UI.new
    @reset = false
    @start_time = Time.new
  end

  def update
    #increse speed every 60 seconds!
#    if (Time::now - @start_time) > 60
#      @start_time = Time.new
#      @step_speed += 1
#      puts "Incresed speed!"
#    end

    @step_time += 1
    if @step_time > (MAX_STEP_SPEED - @step_speed) or Gosu.button_down? Gosu::KB_DOWN

      if @block.grounded?(@stage)
        @stage.add(@block)
        @block = Block.new(Block::SHAPES.keys.sample) unless @pause
      end

      @block.step unless @pause
      @step_time = 0
    end

#    @block.rotate_left if @turn == :left
#    @turn = :none
    if @turn && !@pause
      @block.rotate if @block.rotate_possible?(@stage)
    end
    @turn = false

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
      @block = Block.new(SHAPES.sample)
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
    @turn = true if id == Gosu::KB_UP
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
    #x = ((STAGE_SIZE[0]/2) + STAGE_LEFT_WALL[0])*CELL_SIZE - (@img_game_over.width/2)
    #y = ((STAGE_SIZE[1]/2) + STAGE_LEFT_WALL[1])*CELL_SIZE
    @img_game_over.draw(320,200,2)
    end
=begin
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
=end
  end
end


class Cell

  SIZE = 16
  Z_POS = 1

  attr_reader :image, :color
  attr_accessor :x, :y

  def initialize(x,y, color)
    @x = x
    @y = y
    @color = color
    @image = Gosu::Image.new("test_cell.bmp")
  end

  def draw
    screen_x = x*SIZE #+ offset_x*SIZE
    screen_y = y*SIZE #+ offset_y*SIZE
    image.draw_as_quad(screen_x,screen_y,color,
                       screen_x+SIZE,screen_y,color,
                       screen_x+SIZE,screen_y+SIZE,color,
                       screen_x,screen_y+SIZE,color,Z_POS)
  end

end

class Rectangle

  BORDER = 2

  attr_reader :position, :size, :image

  def initialize(pos,size)
    @position = position_xy(pos)
    @size = size_xy(size)
    @image = Gosu::Image.new("stage.bmp", {tileable:true} )
  end

  def min_x
    position.x
  end

  def min_y
    position.y
  end

  def max_x
    position.x + size.x
  end

  def max_y
    position.y + size.y
  end

  def draw
    border_color = Gosu::Color::RED
    background_color = Gosu::Color::BLACK
    minx, miny = min_x*Cell::SIZE,min_y*Cell::SIZE
    maxx, maxy = max_x*Cell::SIZE,max_y*Cell::SIZE
    image.draw_as_quad(minx-BORDER,miny-BORDER, border_color,
                        maxx+BORDER,miny-BORDER, border_color,
                        maxx+BORDER,maxy+BORDER, border_color,
                        minx-BORDER,maxy+BORDER, border_color, 0)
    image.draw_as_quad(minx,miny, background_color,
                        maxx,miny, background_color,
                        maxx,maxy, background_color,
                        minx,maxy, background_color, 0)
  end

  private

  def position_xy(pos)
    position = Struct.new(:x, :y)
    position.new(pos[0], pos[1])
  end

  def size_xy(size)
    sizexy = Struct.new(:x, :y)
    sizexy.new(size[0], size[1])
  end
end


class Stage

  BORDER = 2
  STAGE_LEFT_WALL = [2,1]

  attr_reader   :rectangle
  attr_accessor :cells

  def initialize(size)
      @cells = []
      @rectangle = Rectangle.new(STAGE_LEFT_WALL,size)
  end

  def draw()
    rectangle.draw
    cells.each { |cell| cell.draw }
  end

  def add(block)
    block.cells.each do |cell|
      self.cells << cell
    end
  end

  def update()
    minx = rectangle.min_x
    miny = rectangle.min_y
    maxx = rectangle.max_x
    maxy = rectangle.max_y

    row_max = maxx - minx
    removed = []

    (miny..maxy).each do |index|
      row = cells.select { |cell| cell.y == index }
      if row.size == row_max
        cells.reject! { |cell| cell.y == index }
        removed << index
      end
    end
    removed.sort!

    cells.each do |cell|
      removed.each do |row|
        cell.y += 1 if row > cell.y
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

  SHAPES = { I:[[-1,0,0xff_00ffff],[0,0,0xff_00ffff],[1,0,0xff_00ffff],[2,0,0xff_00ffff]],
             J:[[0,0,0xff_ff0000],[-1,0,0xff_ff0000],[-1,-1,0xff_ff0000],[1,0,0xff_ff0000]],
             L:[[0,0,0xff_0000ff],[-1,0,0xff_0000ff],[1,0,0xff_0000ff],[1,-1,0xff_0000ff]],
             O:[[0,0,0xff_ffff00],[1,0,0xff_ffff00],[1,1,0xff_ffff00],[0,1,0xff_ffff00]],
             S:[[0,0,0xff_00ffff],[-1,0,0xff_00ffff],[0,-1,0xff_00ffff],[1,-1,0xff_00ffff]],
             T:[[0,0,0xff_808080],[-1,0,0xff_808080],[1,0,0xff_808080],[0,-1,0xff_808080]],
             Z:[[0,0,0xff_ff00ff],[0,-1,0xff_ff00ff],[-1,-1,0xff_ff00ff],[1,0,0xff_ff00ff]] }

  ROTATION_MATRIX = [[0,1],[-1,0]]      # rotation matrix - direction left

  attr_reader :cells, :shape, :pivot
  attr_accessor :x, :y

  def initialize(shape)
    raise ArgumentError.new("Invalid Shape passed! Shape must \
be one of [:I,:J,:L,:O,:S,:T,:Z]!") unless SHAPES.keys.include?(shape)
    @shape = shape
    @cells = cells_array(SHAPES[shape])
    @on_the_block = false
  end

  def rotate_possible?(stage)
    matrix = ROTATION_MATRIX
    temp_cells = []
    pivot = cells[0]
    cells.each do |cell|
      local_x = cell.x - pivot.x
      local_y = cell.y - pivot.y
      new_x = (matrix[0][0]*local_x + matrix[0][1]*local_y) + pivot.x
      new_y = (matrix[1][0]*local_x + matrix[1][1]*local_y) + pivot.y
      temp_cells << Cell.new(new_x, new_y, cell.color)
    end

    temp_cells.each do |cell|
      stage.cells.each do |stage_cell|
        return false if cell.x == stage_cell.x && cell.y == stage_cell.y
      end
    end

    temp_cells_y = []
    temp_cells.each do |cell|
      temp_cells_y << cell.y
    end

    return false if (temp_cells_y.max) >= stage.rectangle.max_y-1
    return false if shape == :O
    return true
  end

  def rotate()
    matrix = ROTATION_MATRIX
    pivot = cells[0]
    cells.each do |cell|
      local_x = cell.x - pivot.x
      local_y = cell.y - pivot.y
      new_x = (matrix[0][0]*local_x + matrix[0][1]*local_y) + pivot.x
      new_y = (matrix[1][0]*local_x + matrix[1][1]*local_y) + pivot.y
      cell.x = new_x
      cell.y = new_y
    end
  end

  def move_right()
    #@x += 1
    cells.each { |cell| cell.x += 1 }
  end

  def move_left()
    #@x -= 1
    cells.each { |cell| cell.x -= 1 }
  end

  def left_empty?(stage)
    #remove colors
    stage_cells_no_col = stage.cells.map { |cell| [cell.x,cell.y] }

    0.upto(3) do |index|
      if stage_cells_no_col.include?([cells[index].x-1,cells[index].y])
        return false
      end
    end
    return true
  end

  def right_empty?(stage)
    stage_cells_no_col = stage.cells.map { |cell| [cell.x,cell.y] }

    0.upto(3) do |index|
      if stage_cells_no_col.include?([cells[index].x+1,cells[index].y])
        return false
      end
    end
    return true
  end

  def offset_right(dx)
    cells.each { |cell| cell.x += dx }
  end

  def offset_left(dx)
    cells.each { |cell| cell.x -= dx }
  end

  def min_x()
    cells_x = []
    0.upto(3) do |index|
      cells_x << cells[index].x
    end
    cells_x.min
  end

  def max_x()
    cells_x = []
    0.upto(3) do |index|
      cells_x << cells[index].x
    end
    cells_x.max
  end

  def min_y()
    cells_y = []
    0.upto(3) do |index|
      cells_y << cells[index].y
    end
    cells_y.min
  end

  def max_y()
    cells_y = []
    0.upto(3) do |index|
      cells_y << cells[index].y
    end
    cells_y.max
  end

  def inside?(stage)
    if stage.rectangle.min_x <= min_x and stage.rectangle.max_x > max_x
      true
    else
      false
    end
  end

  def grounded?(stage)
    @on_the_block = false
    stage_cells_no_col = stage.cells.map do |cell|
      [cell.x,cell.y]
    end

    0.upto(3) do |index|
      if stage_cells_no_col.include?([cells[index].x,cells[index].y+1])
        @on_the_block = true
        return true
      end
      if stage.rectangle.max_y-1 <= max_y
        return true
      end
    end
    return false
  end

  def end_game?(stage)
    if grounded?(stage) && @on_the_block && min_y <= stage.rectangle.min_y
      true
    else
      false
    end
  end

  def move_inside(stage)
    if stage.rectangle.min_x > min_x
      offset_right(stage.rectangle.min_x - min_x)
    end
    if stage.rectangle.max_x <= max_x
      offset_left((max_x - stage.rectangle.max_x) + 1)
    end
  end

  def draw()
    cells.each { |cell| cell.draw }
  end

  def step()
    cells.each { |cell| cell.y += 1 }
  end

  private

  def cells_array(shape)
    arr = []
    shape.each_with_index do |cell|
      arr << Cell.new(cell[0], cell[1], cell[2])
    end
    arr
  end

end

Tetris.new.show
