
class Hangman

  def initialize
    @dictionary_path = "5desk.txt"
    @dictionary = load_dictionary
    @word = ""
    @board = Array.new
    @guess = ""
  end

  def new_game
    @word = choose_word
    new_board
    @guesses = 0
    @used_letters = { correct: [], wrong: [] }

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
    guess
    evaluate_guess
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
    input == "y" ? new_game : exit
  end
end

hangman = Hangman.new

puts "Welcome to Hangman!"

hangman.new_game
