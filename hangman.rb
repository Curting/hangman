
require 'yaml'

class Hangman

  def initialize(word = "", board = [], guesses = 0, used_letters = { correct: [], wrong: [] })
    @dictionary_path = "5desk.txt"
    @dictionary = load_dictionary
    word == "" ? @word = choose_word : @word = word
    @board = board
    @guess = ""
    new_board if @board == []
    @used_letters = used_letters
    @guesses = guesses
  end

  def game
    puts "I'm thinking of a word. Can you guess it?"
    
    until game_over?
      play
    end

    if won?
      puts "WOW! You guessed it. Good job!"
    else
      puts "Ugh. You didn't guess it. Maybe next time :-)"
    end
    puts "The word was #{@word}."

    play_again
  end

  def load_dictionary
    # Load the dictionary from file, clean each word and list
    File.readlines(@dictionary_path).join.split("\r\n").select do |word|
      word.length.between?(5, 12)
    end
  end

  def choose_word
    @dictionary.sample.downcase
  end

  def new_board
    # Create an array with each letter as _
    @board = Array.new(@word.length, "_")
  end

  def show_board
    puts @board.join(" ")
  end

  def show_used_letters
    if @used_letters[:correct].length > 0
      puts "\nCorrect letters: #{@used_letters[:correct].join(', ')}."
    end

    if @used_letters[:wrong].length > 0
      puts "Wrong letters: #{@used_letters[:wrong].join(', ')}."
    end
  end

  def used_letter?
    @used_letters.values.flatten.include?(@guess)
  end

  def game_over?
    won? | lost?
  end

  def won?
    @board.join == @word
  end

  def lost?
    @guesses == 6 && !won?
  end

  def play
    show_board
    show_used_letters
    if @used_letters.values.flatten.length != 0 then save_game end
    guess
    evaluate_guess
  end

  def save_game
    puts "Would you like to save your progress? (Y/n)"

    input = gets.chomp.downcase
    until input == "y" || input == "n"
      puts "Sorry, I didn't understand that? Try again (Y/n):"
      input = gets.chomp.downcase
    end

    if input == "y"
      puts "Great. I'll save your game as a file."
      save_file = { word: @word, board: @board, guesses: @guesses, used_letters: @used_letters }

      save_file_yaml = YAML::dump(save_file)
      File.write("savefile.txt", save_file_yaml)
      
    else
      puts "Alright. Your game has not been saved."
    end
  end

  def guess
    puts "\nGuess a letter (a-z):" 
    @guess = gets.chomp.to_s.downcase
    until !@guess.match(/[a-z]/).nil? && @guess.length == 1 && !used_letter?
      if used_letter?
        puts "You already guessed that. Try another letter (a-z):"
      else
        puts "What? Type one letter in the range a-z:"
      end
      
      @guess = gets.chomp.to_s.downcase
    end
  end

  def evaluate_guess
    correct = false
    count = 0
    @word.each_char.with_index do |char, idx|
      if char == @guess
        @board[idx] = char
        correct = true
        count += 1
      end
    end

    if correct
      puts "\nCorrect! #{count} letter(s) are #{@guess}."
      @used_letters[:correct] << @guess
    else 
      @guesses += 1
      puts "\nWrong. You have #{6 - @guesses} lives left."
      @used_letters[:wrong] << @guess
    end
  end

  def play_again
    puts "\nWould you like to play again? (Y/n)"
    input = gets.chomp.downcase
    until input == "y" || input == "n"
      puts "What? Write Y for yes or N for no:"
      input = gets.chomp.downcase
    end
    input == "y" ? Hangman.new.game : exit
  end
end

puts "Welcome to Hangman!"
puts "\n> [1] Play new game"
puts "> [2] Continue from save file"
puts "\nChoose an option by writing 1 or 2:"

input = gets.chomp
until input == "1" || input == "2"
  puts "I don't understand that. Write '1' or '2':"
  input = gets.chomp
end

if input == "1"
  hangman = Hangman.new
else
  save_file = YAML::load(File.read("savefile.txt"))
  hangman = Hangman.new(save_file[:word], save_file[:board], save_file[:guesses], save_file[:used_letters])
end

hangman.game