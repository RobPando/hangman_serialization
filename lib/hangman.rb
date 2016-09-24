require 'yaml'

class Hangman
	attr_reader :display, :wrong_guesses, :winner

	def initialize
		@wrong_guesses = 0 #Counts the wrong guesses
		random_word #calls method to get a random word
		word_keeper #calls method to obtain and keep that random word privately
		@display = dashes #sets up the dashes according to the length of the word
		@winner = false 
	end

	def draw_stickfigure #draws a nice stickfigure that progresses as the player guesses wrong
		puts " ____"
		puts "|   |"
		print "|   "
		print "O" if @wrong_guesses >= 1
		print "\n|  "
		print "/" if @wrong_guesses >= 2
		print "|" if @wrong_guesses >= 3
		print "\\" if @wrong_guesses >= 4
		print "\n|  "
		print "/" if @wrong_guesses >= 5
		print " \\" if @wrong_guesses >= 6
		puts "\n|"
		puts "TTTTTTTT"
		puts ""
		puts "#{@display}" #displays the progress if player guesses right

	end
	def guess(letter) #public method to recieve guesses from the player
		let = letter.downcase #case insensitive
		@wrong_guesses += 1 unless word_keeper.include? let #adds 1 to the wrong guess if there is no match
		replace(let) if word_keeper.include? let #calls the replace method if letter is included in the word
		draw_stickfigure 
	end

	def show_word #if the player looses
		word = word_keeper
		puts "The word was #{word.join}"
	end

private

	def random_word 
		words = File.readlines "5desk.txt"
		begin
			random_number = rand(words.size)
			@magic_word = words[random_number].downcase.strip 
		end until @magic_word.length >= 5 && @magic_word.length <= 12
		return @magic_word
	end

	def replace(letter) #replaces the dashes with the correct letter
		@winner = true if letter == @the_word.join #if they type the whole word correctly, player wins
		@the_word.each_with_index { |char, index|
				if char == letter
					@display[index] = char
					@the_word[index] = '-'
				end
			}
			check_winner
	end

	def word_keeper
		@the_word = @magic_word.split('')
	end

	def dashes
		dashing = '-'
		begin
			dashing += '-'
		end until dashing.length == @magic_word.length
		return dashing
	end

	def check_winner
		@winner = true unless @display.include?('-')
	end

end

def save(game)
	saving = File.open('lib/saved_hangman.yaml', 'w')
	saving.write(YAML::dump(game))
end
def load
	saved_game = File.open('lib/saved_hangman.yaml', 'r') { |file| file.read }
	YAML.load saved_game
end

################################
####     HANGMAN DISPLAY     ###
################################

puts "Let's play Hangman..."

if File.exists? "lib/saved_hangman.yaml"
	puts "You have a saved game would you like to continue? [y/n]: "
	continue = gets.strip
end

game = continue == 'y' ? load : Hangman.new
game.draw_stickfigure
begin
print "Guess a letter or word (type the number '1' to save): "
letter = gets.strip
	if letter == '1'
		save(game)
		puts "Saved successfully..."
		exit
	end 
game.guess(letter)
end until game.wrong_guesses == 6 || game.winner == true

File.delete("lib/saved_hangman.yaml") if continue == 'y' #delets file if a loaded game ends.
if game.wrong_guesses == 6
	puts "You lost" 
	puts "#{game.show_word}"
end
puts "You won!" if game.winner == true



