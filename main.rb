require_relative 'hangman_display'
require 'json'

module Serialization
    
    @@serializer = JSON
    
    def serialize
        data = {}
        instance_variables.map do |thing|
            data[thing] = instance_variable_get(thing)
        end

        @@serializer.dump data
    end
    
    def deserialize string
        data = @@serializer.parse string
        data.keys.each do |key|
            instance_variable_set(key, data[key])
        end
    end
end

class Game
include Serialization
include HangmanDisplay

    attr_reader :secret_word, :over

    def initialize display
        @secret_word = get_word
        @lives_left = 6
        @over = false
        @win = false
        @correct_guesses = []
        @incorrect_guesses = []

        display_word_progress if display
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

    def display_word_progress
        puts "_____________________________________________"
        puts ""
        puts "Lives left: #{@lives_left}"
        puts "Incorrect guesses: #{@incorrect_guesses}" unless @incorrect_guesses == []
        
        case @lives_left
        when 6 then tree
        when 5 then head
        when 4 then body
        when 3 then right_arm
        when 2 then left_arm
        when 1 then right_leg
        when 0 then left_leg
        end

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
    
    private
    
    def get_word
        word = ''
        until word.length >= 5 && word.length <= 12
            word = File.readlines('5desk.txt')[rand(61406)].strip
        end
        word
    end

end

class Player
    def make_guess
        puts "\nTo save and exit, type 'save'"
        puts "\nGuess a letter:"
        guess = gets.chomp.downcase

        until guess.length == 1 || guess == "save"
            puts "\nYou can only guess one letter at a time."
            puts "Guess a letter:"
            guess = gets.chomp.downcase
        end
        guess
    end
end

if File.exists? "hangman-save.txt"
    puts "Want to load the last saved game? (y/n)"
    input = gets.chomp.downcase.strip
end

puts "\nThe computer has chosen a randomly selected word and hidden it."
puts "\nTry to guess the computer's secret word before running out of lives."

if input == "y"
    game = Game.new false
    game.deserialize File.open("hangman-save.txt", "r"){|file| file.read}
    game.display_word_progress
else 
    game = Game.new true
end
player = Player.new

until game.over
    guess = player.make_guess

    break if guess == "save"

    game.check_guess guess
end

if game.over
    game.end_result
    puts "The word was: #{game.secret_word}"
else
    save = game.serialize
    File.open("hangman-save.txt", "w"){|file| file.puts save}
    puts "\nGame saved."
end