require 'set'


class Hangman
  @@comands = {
    help: 'Displays the list of commands',
    save: 'Saves the current game and quits to the main menu',
    quit: 'Quits the current game to the main menu'
  }

  def initialize(min_len=5, max_len=12, max_wrong=8)
    @min_len = min_len
    @max_len = max_len
    @max_wrong = max_wrong

    @secret = ''
    @guessed = Set.new
  end


  def main_menu
    puts ''
    puts 'Welcome to Hangman!'
    puts '1. New game'
    puts '2. Load game'
    puts '3. Quit'

    print 'Chose an option: '
    choice = gets.chomp
    until choice_valid?(choice, 3)
      print 'Choice must be between 1 and 3: '
      choice = gets.chomp
    end

    puts
    case choice
    when '1'
      new_game
    when '2'
      load_game_menu
    end
  end


  def new_game
    @secret = rand_word
    puts 'Let\'s play Hangman!'
    
    if game_loop?
      # Prematurely exit the game
    else
      display_results
    end
    main_menu
  end


  def load_game_menu
    saves = Dir.exist?(:saves) ? Dir.entries(:saves) - ['..', '.'] : []
    if saves.empty?
      puts 'No saves found, returning to main menu...'
      return main_menu
    end

    saves.each_with_index do |val, index|
      puts "#{index+1}. #{val}"
    end
  end


  private


  def rand_word
    words = File.readlines('google-10000-english-no-swears.txt').map { |word| word.chomp }.select do |word|
      word.length >= @min_len and word.length <= @max_len
    end
    words.sample
  end


  def get_incorrect
    (@guessed - @secret.chars).sort
  end
  

  def display_guess
    puts @secret.chars.map { |c| @guessed.include?(c) ? c : '_' }.join(' ')
  end


  def display_incorrect
    incorrect = get_incorrect
    puts "Incorrect guesses (#{incorrect.length}/#{@max_wrong}): #{incorrect.join(', ')}"
  end


  def display_results
    if @secret.chars.all?{ |c| @guessed.include? c}
      puts 'You wins! :D'
    else
      puts 'You loses :('
      puts "The word was `#{@secret}`"
    end
  end


  def input_valid?(input)
    guess_valid?(input) or command_valid?(input)
  end


  def command_valid?(command)
    @@comands.keys.map { |k| k.name }.include? command
  end

  
  def guess_valid?(guess)
    guess.length == 1 and guess.match(/^[[:alpha:]]+$/)
  end


  def choice_valid?(input, max_index)
    int = Integer(input) rescue -1
    int.between?(1, max_index)
  end


  # Returns true if we quit the game before it ended
  def game_loop?
    display_commands
    display_game

    until game_over?
      print 'Guess a letter: '
      input = gets.chomp
      
      until input_valid?(input)
        puts 'Invalid letter!'
        display_game
    
        print 'Guess a letter: '
        input = gets.chomp
      end

      if guess_valid? input
        @guessed << input.downcase
      elsif command_valid? input
        return true if execute_command? input
      end
      display_game
    end
    false
  end


  def display_game
    puts ''
    display_guess
    display_incorrect
  end


  def display_commands
    puts ''
    puts 'Commands:'
    for k, v in @@comands
      puts "   #{k} - #{v}"
    end
  end


  # Returns true when we want to quit the current game
  def execute_command?(input)
    case input
    when 'help'
      display_commands
    when 'save'
      return true
    when 'quit'
      return true
    end
    false
  end


  def game_over?
    incorrect = get_incorrect
    @secret.chars.all?{ |c| @guessed.include? c} or incorrect.length == @max_wrong
  end


  def save_game
  end


  def load_game
  end
end


hangman = Hangman.new
hangman.main_menu