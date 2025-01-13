require 'set'


class Hangman
  def initialize(min_len=5, max_len=12, max_wrong=8)
    @min_len = min_len
    @max_len = max_len
    @max_wrong = max_wrong

    @secret = ''
    @guessed = Set.new
  end


  def main_menu
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
      load_menu
    else
      return
    end
  end


  def new_game
    @secret = rand_word
    puts 'Let\'s play Hangman!'
    game_loop
    display_results
  end


  def load_menu
    saves = Dir.exist?('saves') ? Dir.entries('saves') - ['..', '.'] : []
    if saves.empty?
      puts 'No saves found, returning to main menu...'
      return
    else
      saves.each_with_index do |val, index|
        puts "#{index+1}: #{val}"
      end
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
    (@guessed.to_a - @secret.chars).sort
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


  def guess_valid?(input)
    input.length == 1 and input.match(/^[[:alpha:]]+$/)
  end

  def choice_valid?(input, max_index)
    int = Integer(input) rescue -1
    int.between?(1, max_index)
  end


  def game_loop
    display_game
    until game_over?
      print 'Guess a letter: '
      guess = gets.chomp
    
      until guess_valid?(guess)
        puts 'Invalid letter!'
        display_game
    
        print 'Guess a letter: '
        guess = gets.chomp
      end
      @guessed << guess.downcase
      display_game
    end
  end

  def display_game
    puts ''
    display_guess
    display_incorrect
  end


  def game_over?
    incorrect = get_incorrect
    @secret.chars.all?{ |c| @guessed.include? c} or incorrect.length == @max_wrong
  end
end


hangman = Hangman.new
hangman.main_menu