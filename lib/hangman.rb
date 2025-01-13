require 'set'

MIN_LEN = 5
MAX_LEN = 12

MAX_WRONG = 8

def display_guess(secret, guessed)
  puts secret.chars.map { |c| guessed.include?(c) ? c : '_' }.join(' ')
end

def get_incorrect(secret, guessed)
  (guessed.to_a - secret.chars).sort
end

def display_incorrect(secret, guessed)
  incorrect = get_incorrect(secret, guessed)
  puts "Incorrect guesses (#{incorrect.length}/#{MAX_WRONG}): #{incorrect.join(', ')}"
end

def display(secret, guessed)
  puts ''
  display_guess(secret, guessed)
  display_incorrect(secret, guessed)
end

def game_over?(secret, guessed)
  incorrect = get_incorrect(secret, guessed)
  secret.chars.all?{ |c| guessed.include? c} or incorrect.length == MAX_WRONG
end

words = File.readlines('google-10000-english-no-swears.txt').map { |word| word.chomp }.select do |word|
  word.length >= MIN_LEN and word.length <= MAX_LEN
end

puts 'Let\'s play Hangman! Try figure out the word, or type `quit` to exit.'
secret = words.sample
# puts secret

guessed = Set.new
display(secret, guessed)

until game_over?(secret, guessed)
  print 'Guess a letter: '
  guess = gets.chomp
  if guess == 'quit'
    return
  end

  until guess.length == 1 and guess.match(/^[[:alpha:]]+$/)
    puts 'Invalid option!'
    display(secret, guessed)

    print 'Guess a letter: '
    guess = gets.chomp
    if guess == 'quit'
      return
    end
  end
  guessed << guess.downcase
  display(secret, guessed)
end

if secret.chars.all?{ |c| guessed.include? c}
  puts 'You wins! :D'
else
  puts 'You loses :('
  puts "The word was `#{secret}`"
end
