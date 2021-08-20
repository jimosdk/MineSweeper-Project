require 'colorize'
require 'colorized_string'

# String.disable_colorization = false
# ColorizedString.disable_colorization = false
class Tile

    attr_accessor :value

    def initialize(value)
        @value = value                       # -1 : bomb,(1 - 8) : # of adjacent bombs or 0:interior
        @revealed = false
        @flagged = false
    end

    def flagged?
        @flagged.dup
    end
    
    def toggle_flag  
        @flagged = !@flagged unless revealed?
        nil
    end

    def revealed? 
        @revealed.dup 
    end

    def reveal 
        @revealed = true unless flagged?
        nil
    end

    def to_s
        #debugger
        if flagged?
            "F".colorize(:color => :red ,:background => :light_black)
        elsif !revealed?
            " ".colorize(:background => :light_black) 
        elsif  value == -1
            "X".colorize(:color => :light_red)
        elsif  value == 0
            "_".colorize(:color => :light_white)
        else  
            value.to_s.colorize(color)
        end
    end

    def color
        case value 
        when 1
            {:color => :light_blue}
        when 2
            {:color => :light_cyan}
        when 3
            {:color => :light_green}
        when 4
            {:color => :blue}
        when 5
            {:color => :cyan}
        when 6
            {:color => :green}
        when 7
            {:color => :light_magenta}
        when 8
            {:color => :magenta}
        end
    end

    def bomb?
        value == -1
    end

    def no_adjacent_bombs
        value == 0
    end




end

if __FILE__ == $PROGRAM_NAME
    tile1 = Tile.new(4)
    tile2 = Tile.new(0)
    tile3 = Tile.new(-1)

    puts tile1.to_s
    tile1.toggle_flag
    puts tile1.to_s
    tile1.toggle_flag
    tile1.reveal
    puts tile1.to_s

    puts tile2.to_s
    tile2.toggle_flag
    puts tile2.to_s
    tile2.toggle_flag
    tile2.reveal
    puts tile2.to_s

    puts tile3.to_s
    tile3.toggle_flag
    puts tile3.to_s
    tile3.toggle_flag
    tile3.reveal
    puts tile3.to_s
    

end