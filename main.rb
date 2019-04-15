class Game
    attr_reader :secret_word, :over

    def initialize
        @secret_word = get_word
        @lives_left = 6
        @over = false
        @win = false
        @correct_guesses = []
        @incorrect_guesses = []

        display_word_progress
    end

    public
    
    def check_guess player_guess
        secret_letters = @secret_word.downcase.split("")
        if secret_letters.include? player_guess
            @correct_guesses << player_guess
        else
            @incorrect_guesses << player_guess
            @lives_left -= 1
        end
        
        display_word_progress
        
        @over = true if @lives_left == 0
    end
    
    def end_result
        puts @win? "\nCongratulations, you guessed the word!" : "\nYou ran out of lives!"
    end

    private

    def get_word
        word = ''
        until word.length >= 5 && word.length <= 12
            word = File.readlines('5desk.txt')[rand(61406)].strip
        end
        word
    end

    def display_word_progress
        puts "_____________________________________________"
        puts ""
        puts "Lives left: #{@lives_left}" unless @lives_left > 5
        puts "Incorrect guesses: #{@incorrect_guesses}" unless @incorrect_guesses == []

        word_progress = @secret_word.split("").map do |letter|
            letter = "_" unless @correct_guesses.include? letter.downcase
            letter
        end

        if word_progress.join == @secret_word
            @win = true
            @over = true
        end
        puts ""
        puts word_progress.join("  ")
    end
end

class Player

    def make_guess
        puts "\nGuess a letter:"
        guess = gets.chomp.downcase
        until guess.length == 1
            puts "\nYou can only guess one letter at a time."
            puts "Guess a letter:"
            guess = gets.chomp.downcase
        end
        guess
    end
end

puts "\nThe computer has chosen a randomly selected word and hidden it."
puts "\nTry to guess the computer's secret word before running out of lives."

game = Game.new
player = Player.new

until game.over
    guess = player.make_guess
    game.check_guess guess
end
game.end_result
puts "The word was: #{game.secret_word}"