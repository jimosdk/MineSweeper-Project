require './tiles.rb'

class Board

    def self.create_board(dimension,dimension_2,no_of_bombs)
        grid = Board.create_empty_grid(dimension,dimension_2)
        grid = Board.place_bombs(grid,no_of_bombs) 
        grid = Board.set_adjacent_bomb_values(grid)  
        self.new(grid)
    end

    def self.create_empty_grid(dimension,dimension_2)
        grid = Array.new(dimension) {Array.new(dimension_2) {Tile.new(nil)}}
    end

    def self.place_bombs(grid,no_of_bombs)
        x = nil
        y = nil
        no_of_bombs.times do
            loop do
                x = rand(0..grid.length - 1)
                y = rand(0..grid.first.length - 1)
                break if grid[x][y].value.nil?
            end
            grid[x][y].value = -1
        end
        grid
    end

    def self.set_adjacent_bomb_values(grid)
        (0...grid.length).each do |row|
            (0...grid.first.length).each do |col|
                unless grid[row][col].bomb?
                grid[row][col].value = Board.number_of_adjacent_bombs(grid,row,col)   
                end
            end
        end
        grid                         
    end

    def self.number_of_adjacent_bombs(grid,row,col)
        (-1..1).inject(0) do |adj_bombs,row_offset|
            adj_bombs + (-1..1).count do |col_offset|
                adj_row = row + row_offset
                adj_col = col + col_offset
                next if adj_row >= grid.length || adj_row < 0
                next if adj_col >= grid.first.length || adj_col < 0
                grid[adj_row][adj_col].bomb? unless grid[adj_row][adj_col] == grid[row][col]
            end
        end
    end

    def initialize(grid)
        @grid = grid
    end

    def bomb_revealed?
        @grid.any? do |row| 
            row.any?{|tile| tile.bomb? && tile.revealed?}
        end
    end

    def all_safe_tiles_revealed?
        @grid.all? do |row| 
            row.all? do |tile|
                tile.revealed? || (!tile.revealed? && tile.bomb?)
            end
        end 
    end

    def size
        [@grid.length,@grid.first.length]
    end

    def [](pos)
        x,y = pos
        @grid[x][y]
    end

    def render
        print " "
        (0...@grid.first.length).to_a.each do |col|
            print "%3d"  %[col]
        end
        puts
        @grid.each_with_index do |row,idx|
            print "%-03d" %[idx] 
            puts "#{row.map(&:to_s).join("  ")}\n\n"
        end
        nil
    end

    def bomb?(pos)
        self[pos].bomb?
    end

    def reveal(pos)
        neighbour_tiles = [pos]
        already_checked = []
        until neighbour_tiles.empty?
            pos = neighbour_tiles.shift
            already_checked << pos
            self[pos].reveal
            if self[pos].no_adjacent_bombs
                neighbour_tiles += find_neighbours(pos)
                neighbour_tiles = neighbour_tiles.uniq - already_checked
            end
        end
    end

    def find_neighbours(pos)
        row,col = pos
        (-1..1).map do |row_offset|
            arr = []
            (-1..1).each do |col_offset|
                adj_row = row + row_offset
                adj_col = col + col_offset
                next if adj_row >= @grid.length || adj_row < 0
                next if adj_col >= @grid.first.length || adj_col < 0
                arr << [adj_row,adj_col] unless @grid[adj_row][adj_col] == @grid[row][col] || @grid[adj_row][adj_col].revealed?
            end
            arr
        end.flatten(1)
    end
        

    def toggle_flag(pos)
        self[pos].toggle_flag
    end

    def cheat_render
        cols =(0...@grid.first.length).to_a.join(" ")
        puts "  #{cols}"
        @grid.each_with_index do |row,idx|
            puts "#{idx} #{row.map{|tile| tile.bomb? || tile.flagged? ? tile.to_s : tile.value.to_s}.join(" ")}\n\n"
        end
        nil
    end
end


if __FILE__ == $PROGRAM_NAME
    board = create_board(9,9,10)
    p board
end