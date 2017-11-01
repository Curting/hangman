
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
      puts "What should we name the save file?"
      fname = gets.chomp.downcase

      until fname == fname[/[a-z]+/]
        puts "What? Please only use one word (a-z):"
        fname = gets.chomp.downcase
      end

      Dir.mkdir('savefiles') if !Dir.exist?('savefiles')

      puts "\nSaving your game as '#{fname}'..."

      save_file_yaml = YAML::dump(save_file)
      File.write("savefiles/#{fname}.txt", save_file_yaml)
      sleep(2)
      puts "Your game has been saved."
      sleep(1)
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

def load_game
  file_list = Dir.entries('savefiles')[2..-1]
  puts "Choose a savefile:"

  # Splice to remove the "." and ".." in the Dir
  file_list.each_with_index do |fname, idx|
    # Splice to remove the .txt extension and idx + 1 to start from 1
    puts "> [#{idx + 1}] #{fname[0..-5]}"
  end

  # -1 to return to a idx starting from 0
  file_idx = gets.chomp.to_i - 1
  until !file_list[file_idx].nil? && file_idx >= 0
    puts "\nThat index doesn't exist for a savefile. Try again:"
    file_idx = gets.chomp.to_i - 1
  end

  puts "\nLoading #{file_list[file_idx][0..-5]}...\n\n"
  sleep(2)

  save_file = YAML::load(File.read("savefiles/#{file_list[file_idx]}"))
  Hangman.new(save_file[:word], save_file[:board], save_file[:guesses], save_file[:used_letters]).game
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
  Hangman.new.game
else
  load_game
end