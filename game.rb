require './board'
require 'yaml'
require 'colorize'

class MineSweeper
    attr_accessor :board
    def self.create_game(difficulty = "beginner")

        case difficulty
        when "beginner"
            dim1,dim2,bombs = 9,9,10
        when "intermediate"
            dim1,dim2,bombs = 13,15,40
        when "expert"
            dim1,dim2,bombs = 16,30,99
        end
        board = Board.create_board(dim1,dim2,bombs)
        self.new(board,difficulty,bombs)
    end

    def self.print_all_save_states
        saves_hash_yaml = File.read("save_file.json")
        saves_hash = YAML::load(saves_hash_yaml)
        i = 0
        saves_hash.each do |save_name,save_state|
            diff,score,game = save_state
            puts "Save ##{i}".colorize(:color => :magenta)
            MineSweeper.print_save_state(save_name,[diff,score])
            i += 1
        end
        return false if saves_hash.empty?
        true
    end

    def self.print_save_state(save_name,save_state)
        name , time = save_name
        diff, score = save_state
        revealed,total = score
        puts "-------------------------------"
        puts name.colorize(:color => :light_blue)
        puts time.colorize(:color => :cyan)
        puts diff.colorize(:color => :red)
        print "Revealed Squares : "
        print revealed.to_s.colorize(:color => :light_cyan)
        puts "/" + total.to_s.colorize(:color => :blue)
        puts "-------------------------------"
        nil
    end

    def self.delete_game(idx)
        saves_hash_yaml = File.read("save_file.json")
        saves_hash = YAML::load(saves_hash_yaml)

        save_name = saves_hash.keys[idx]

        diff,score,game = saves_hash[save_name]
        system("clear")
        MineSweeper.print_save_state(save_name,[diff,score])
        
        saves_hash.delete(save_name)

        saves_hash_yaml = saves_hash.to_yaml
        File.write("save_file.json",saves_hash_yaml)

        puts "\n      SAVE DELETED!\n\n"
        sleep(3)
    end

    def self.load_game(idx)
        saves_hash_yaml = File.read("save_file.json")
        saves_hash = YAML::load(saves_hash_yaml)

        save_name = saves_hash.keys[idx]
        diff,score,game = saves_hash[save_name]

        system("clear")
        MineSweeper.print_save_state(save_name,[diff,score])
        puts "\n      LOAD COMPLETE!\n\n"
        sleep(3)
        game
    end

    def save_game(name)
        score =[]
        save_name =[]
        time = Time.new
        dim1,dim2 = @board.size
        number_of_tiles = dim1 * dim2

        score = [number_of_tiles_revealed,number_of_tiles - @number_of_bombs]
        save_name = [name,
        "#{time.year}-#{time.month}-#{time.day} #{time.hour}:#{time.min}:#{time.sec}"]
        state = [@difficulty,score,self]

        MineSweeper.print_save_state(save_name,state)

        saves_hash_yaml = File.read("save_file.json")
        saves = YAML::load(saves_hash_yaml)

        saves[save_name] = state
        saves_hash_yaml = saves.to_yaml
        File.write("save_file.json",saves_hash_yaml)

        puts "\nSAVE COMPLETED\n\n"
        sleep(3)
        # system("clear")
    end


    def number_of_tiles_revealed
        dim1,dim2 = @board.size
        (0...dim1).inject(0) do |acc,row| 
            acc + (0...dim2).count do |col|
                @board[[row,col]].revealed? 
            end
        end
    end


    def initialize(board,difficulty,number_of_bombs)
        @difficulty = difficulty
        @board = board
        @number_of_bombs = number_of_bombs
    end

    

    def run
        quit = false
        quit = turn until game_over? || quit
        return system('clear') if quit
        lose? ? prompt(3) : prompt(2)
        system('clear')
    end
    def win?
       @board.all_safe_tiles_revealed? 
    end

    def lose?
        @board.bomb_revealed?
    end

    def game_over?
       win? || lose?
    end

    def turn 
        pos = [-1,-1]
        flag = nil
        quit = false
        until valid_pos?(pos)
            prompt(1)
            flag,pos = parse_input(gets.chomp)
            prompt(4) unless valid_pos?(pos)
        end
        if flag == "f" || flag == "F"
            @board.toggle_flag(pos)
        elsif flag == "q"
            quit = true
        elsif flag == "s"
            system('clear')
            print "Save file name : "
            save_game(gets.chomp)
        else
            @board.reveal(pos)
        end
        quit
    end

    def valid_input?(input)
        arr = input.split(" ")
        (arr.length == 2 || arr.length == 3 || arr.length == 3) && 
            (arr[0].to_i.to_s == arr[0] && arr[1].to_i.to_s == arr[1]) ||
             arr[0] == "q" || arr[0] == "s"||
            (arr[0] == "f" && arr[1].to_i.to_s == arr[1] && arr[2].to_i.to_s == arr[2] )
    end

    def valid_pos?(pos)
        dim1,dim2 = @board.size
        row,col = pos
        row.between?(0,dim1 -1) && col.between?(0,dim2 -1)
    end

    def parse_input(input)
        return [nil,[-1,-1]] unless valid_input?(input)
        arr = input.split(" ")
        if arr[0] == "f"
            pos = arr[1..2].map(&:to_i)
            flag = arr[0]
        elsif arr[0] == "q" || arr[0] == "s"
            pos = [0,0]
            flag = arr[0]
        else
            pos = arr[0..1].map(&:to_i)
            flag = nil
        end
        [flag,pos]
    end

    def prompt(cmd)
        system('clear')
        @board.render
        case cmd
        when 1
            puts "\ns:Save"
            puts "q:Quit"
            puts "f:Flag"
            print "\n Choose a square (ex. f 3 4 ): "
        when 2
            puts "\n    You win! \n\n"
            sleep(5)
        when 3
            puts "\n ...Game over...\n\n"
            sleep(4)
        when 4
            puts "\n ...Invalid input...\n\n"
            sleep(2)
        end
    end
end


def prompt(cmd)
    system('clear')
    flag = true
    case cmd
    when 1
        puts "MINESWEEPER".colorize(:color => :magenta)
        puts "\n\n\nn:New Game"
        puts "l:Load Game"
        puts "q:Quit"
        print ">:"  
    when 2
        puts "\n\n\n1:beginner"
        puts "2:intermediate"
        puts "3:expert"
        puts "b:Back"
        print ">:" 
    when 3
        puts "\n ...Invalid Input...\n\n "
        sleep(2)
    when 4
        puts "\n\n\n...Empty..."
        sleep(2)
    when 5
        flag = MineSweeper.print_all_save_states
        puts "\n\n\nd #:Delete Save #"
        puts "b:Back"
        puts "Choose Save file (by number)"
        print ">:"
    end

    flag
end

if __FILE__ == $PROGRAM_NAME
    
  loop do 
    prompt(1)
    input = gets.chomp
    case input
    when "n"
        loop do 
            prompt(2)
            input = gets.chomp
            case input
            when "1"
                game = MineSweeper.create_game("beginner")
                game.run
                break
            when "2"
                game = MineSweeper.create_game("intermediate")
                game.run
                break
            when "3"
                game = MineSweeper.create_game("expert")
                game.run
                break
            when "b"
                break
            else
                prompt(3)
            end
        end
    when "l" 
            loop do 
                break prompt(4) unless prompt(5)
                input = gets.chomp
                if input == "b"
                    break
                elsif input[0] == "d"
                    input = input.split
                    MineSweeper.delete_game(input[1].to_i)
                elsif input.to_i.to_s == input
                    game = MineSweeper.load_game(Integer(input))
                    game.run
                    break
                else
                    prompt(3)
                end  
            end        
    when "q"
        break
    else
        prompt(3)
    end
  end
  system('clear')
end

