require 'set'
require_relative 'is_integer'

def display_options(options)
  puts 'Options:'
  for k, v in options
    puts "  #{k.name.ljust 10} - #{v}"
  end
end


def option_valid?(options, choice)
  options.keys.map { |k| k.name }.include? choice
end


class HangmanManager
  SAVE_DIR = 'saves'

  @@main_menu_options = {
    new: 'Start a new game',
    load: 'Load a previous game',
    quit: 'Closes program'
  }


  def initialize
    puts
    puts 'Welcome to Hangman!'
    
    while true
      case main_menu
      when :new
        new_game
      when :load
        load_game_menu
      when :quit
        puts 'Thanks for playing!'
        break
      end
    end

  end


  def main_menu
    puts
    display_options @@main_menu_options

    print 'Pick an option: '
    choice = gets.chomp
    until option_valid?(@@main_menu_options, choice)
      print 'Invalid choice! Try again: '
      choice = gets.chomp
    end
    choice.to_sym
  end


  def new_game
    h = Hangman.new
    case h.play
    when :save
      puts 'Saving and quitting to main menu...'
      Dir.mkdir SAVE_DIR unless Dir.exist? SAVE_DIR
      File.open("#{SAVE_DIR}/#{Time.now.to_i}.hm", 'wb') { |f| f.write(Marshal::dump(h)) }
    when :quit
      puts 'Returning to main menu...'
    when :won
      puts 'You wins! :D'
    when :lost
      puts 'You loses :('
      puts "The word was `#{h.secret}`"
    end
  end


  def load_game_menu
    puts
    saves = Dir.exist?(SAVE_DIR) ? Dir["#{SAVE_DIR}/*.hm"] : []
    if saves.empty?
      puts 'No saves found, returning to main menu...'
      return
    end

    titles = ['Index', 'Progress', 'Last Played']
    progress_list = []
    last_played_list = []
  
    saves.each_with_index do |path, index|
      game = Marshal.load(File.read(path))
      
      progress_list << game.get_guesssed
      last_played_list << File.mtime(path).to_s
    end

    lengths = [
      titles[0].length,
      ([titles[1]] + progress_list).max_by(&:length).length,
      ([titles[2]] + last_played_list).max_by(&:length).length
    ]

    title = (0...titles.length).map { |i| titles[i].ljust(lengths[i])}.join ' | '
    puts title
    puts '-' * title.length

    saves.each_with_index do |save, index|
      rows = [
        (index + 1).to_s.ljust(lengths[0]),
        progress_list[index].ljust(lengths[1]),
        last_played_list[index].ljust(lengths[2])
      ]
      puts rows.join ' | '
    end

    # puts
    # print 'Select which save to load: '
    # input = gets.chomp
    # until input.is_integer? and input.to_i.between?(1, saves.length)
    #   print 'Try again: '
    #   input = gets.chomp
    # end
  end
end


class Hangman
  @@commands = {
    save: 'Save and quit the current game',
    quit: 'Return to main menu without saving'
  }


  def initialize(min_len=5, max_len=12, max_wrong=8)
    @min_len = min_len
    @max_len = max_len
    @max_wrong = max_wrong

    @secret = rand_word
    @guessed = Set.new
  end


  def play
    puts
    puts "Let\'s play Hangman!"
    display_options @@commands
    display_game

    while game_status == :ongoing
      print 'Guess a letter: '
      input = gets.chomp
      
      until input_valid?(input)
        print 'Invalid input! Try again: '
        input = gets.chomp
      end

      if guess_valid? input
        @guessed << input.downcase
        display_game
      elsif option_valid?(@@commands, input)
        return input.to_sym
      end
    end

    return game_status
  end


  def rand_word
    words = File.readlines('google-10000-english-no-swears.txt').map { |word| word.chomp }.select do |word|
      word.length >= @min_len and word.length <= @max_len
    end
    words.sample
  end


  def get_incorrect
    (@guessed - @secret.chars).sort
  end
  

  def get_guesssed
    @secret.chars.map { |c| @guessed.include?(c) ? c : '_' }.join(' ')
  end


  def display_incorrect
    incorrect = get_incorrect
    puts "Incorrect guesses (#{incorrect.length}/#{@max_wrong}): #{incorrect.join(', ')}"
  end


  def input_valid?(input)
    guess_valid?(input) or option_valid?(@@commands, input)
  end

  
  def guess_valid?(guess)
    guess.length == 1 and guess.match(/^[[:alpha:]]+$/)
  end


  def display_game
    puts
    puts get_guesssed
    display_incorrect
  end


  def game_status
    if @secret.chars.all?{ |c| @guessed.include? c}
      :won
    elsif get_incorrect.length == @max_wrong
      :lost
    else
      :ongoing
    end
  end
end


HangmanManager.new