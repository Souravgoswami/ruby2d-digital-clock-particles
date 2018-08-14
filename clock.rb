#!/usr/bin/env ruby
# Created by Sourav Goswami, thanks to ruby2d
# This digital clock is tested on GNU/Linux 64 bit OS with i3 6th gen processor.
# The result is not bad. But more Particles = more RAM and CPU usage.
# Change the fonts if it doesn't suit you!
# I wanted to make all in a single file to keep things simple. That means more time to scroll up and down.
# This is designed to keep in a exported path, so that it can be run directly from the linux terminal!
#
# TIPS:
# Change the <textfont = path + (Dir.entries path).sample> with your font if the program has some font issue and crashes

begin
	require 'ruby2d'

rescue LoadError => err
	puts "An error occured:\n\t#{err}\nThat means Ruby2D is not yet installed :("
	abort "For more info, visit:\033[1;34m http://www.ruby2d.com/learn/get-started/"

else
	# A class to handle other objects easily
	class Particles
		attr_reader :hash, :square
		# Get the Hash, which is used later part to make things easier...
		def initialize(hash)
			@hash = hash
		end

		# Create a Square object from Ruby2d library. Takes two optional parametres
		def self.square()
			extend Ruby2D::DSL
			size = rand(10..50)
			colour = $colours.sample
			z = 1
			Square.new x: rand(0..$width) ,y: rand(0..$height), size: size, color: colour, z: z
		end

		# Change the position of the objects accordingly (used in loop)
		def draw(down=false, right=false, left=false)
			@hash.values.each { |n| if down then n.y += 1 ; else n.y -= 1 end
				n.x += 1 if right
				n.x -= 1 if left
				n.opacity -= rand(0.005..0.01)	}
		end

		# Control the opacity of the objects
		def alpha(obj, magical=false)
			obj.opacity = rand(0.2..1) if obj.opacity <= 0.1 and !magical
			obj.opacity = rand(0.1..0.5) if obj.opacity < 0.1 and magical
		end

		# Change the position of particles, randomly!
		def change
			@hash.values.each do |n|
				n.y=  rand(0..$height) if n.y <= 0 or n.y >= $height
				n.x = rand(0..$width) if n.x <= 0 or n.x >= $width
				alpha(n)
			end
		end
end

class MagicParticles < Particles
	attr_reader :hash
	def initialize(hash)
		@hash = hash
	end

	def self.square(fizz=false)
		extend Ruby2D::DSL
		size, colour = rand(10..15), []

		unless fizz
			magical_colours = %w(yellow white green lime silver orange)
			until colour.length == 4 do colour << magical_colours.delete(magical_colours.sample) ; end
		else
			colour = 'white'
		end

		# Create a new Square object for MagicalParticle!
		Square.new x: rand(0..$width) ,y: rand(0..$height), size: size, color: colour, z: -1
	end

	def pos(posx, posy)
			object = @hash.values.sample
			object.x, object.y, object.z = posx, posy, 1
			alpha(object, true)
	end
end

	def main()
		$width, $height = 640, 480
		all_colours = %w(#3ce3b5 fuchsia orange blue white green red #E58AE8 #EB65BB #FFFFFF)
		$colours, colour = [], []
		until colour.length == 4 do colour << all_colours.delete(all_colours.sample) ; end
		colour.permutation { |i| $colours << i }

		# Get the user's home path to load some local fonts. If you are encountering problems, change it!
		path = "#{ENV['HOME']}/.local/share/fonts/"
		textfont = path + (Dir.entries path).sample
		# Works nice with textfont = path + "ArimaKoshi-Bold.otf"	# You can use your favourite font too!
		puts "Using #{textfont} font"

		p = Proc.new { |f| Time.new.strftime(f) }
		time, boxes = p.call('%s'), true

		set title: "Clock", width: 640, height: 480, resizable: true

		# Some hardcoded values!
		date = Text.new x: 185, y: 80, font: textfont, size: 60, text: p.call('%D'), z: 2
		tm = Text.new x: 160, y: 180, font: textfont, size: 60, text: p.call('%T:%N'), z: 2
		day  = Text.new x: 200, y: 280, font: textfont, size: 60, text: p.call('%A'), z: 2
		message = Text.new x: 170, y: 380, font: textfont, size: 30, text: p.call('%c'), z: 0
		greeting = Text.new x: 180, y: 30, font: textfont, size: 40, text: "Hello!", z: 0
		qd = Quad.new x2: $width, x3: $width, y3: $height, y4: $height, color: $colours.sample

		# Create hashes, and store Square objects in the hash
		h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, s = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, Particles
		for i in 1..rand(5..10) do
			h1.merge! "sq#{i}": s.square ; h2.merge! "sq#{i}": s.square
			h3.merge! "sq#{i}": s.square ; h4.merge! "sq#{i}": s.square
			h5.merge! "sq#{i}": s.square ; h6.merge! "sq#{i}": s.square
		end

		# Store small particles in the hash, that will be shown on :mouse_move and to show white small squares
		s = MagicParticles
		for i in 1..20
			h7.merge! "sq#{i}": s.square ; h8.merge! "sq#{i}": s.square
			h9.merge! "sq#{i}": s.square ; h10.merge! "sq#{i}": s.square(true)
			h11.merge! "sq#{i}": s.square(true) ; h12.merge! "sq#{i}": s.square(true)
		end

		# Hashes are passed to Particles, and assigned to obj1 to obj12. This will help to use the draw, change, and pos  methods
		obj7, obj8, obj9, obj10, obj11, obj12 = s.new(h7), s.new(h8), s.new(h9), s.new(h10), s.new(h11), s.new(h12)

		s = Particles
		obj1, obj2, obj3, obj4, obj5, obj6 = s.new(h1), s.new(h2), s.new(h3), s.new(h4), s.new(h5), s.new(h6)

		# Get mouse press events
		on :mouse_down do  |e|
			# Change the background colour (index 1) when the mouse is pressed!
			qd.color = $colours.rotate![1]

			obj1.change ; obj2.change

			# Show the Good Morning etc. messages, and also a proper 12H time format when the mouse is pressed
			message.text = p.call('%a, %b %d, %I:%M %p')
			message.z = greeting.z = 2
			message.x, greeting.x = 170, 180
			message.y, greeting.y = 380, 30
			message.opacity = greeting.opacity = 1

			# Get the current time in 1..23 hour format, required just below!
			t = p.call('%H').to_i

			# Get the greeting text! Morning time = Good Morning!...
			if t >=  5 and t < 12 then greeting.text = "Good Morning!..."
			elsif t >=  12 and t < 16 then greeting.text = "Good Afternoon."
			elsif t >=  16 and t < 19 then greeting.text = "Good Evening!!..."
			else greeting.text = "Very Good Night" ; end
			20.times do
				obj10.pos(rand(0..100), rand(0..$height))
				obj11.pos(rand($width - 100..$width), rand(0..$height))
			end
			boxes = true
			# Draw Square objects that are also activated when mouse_move. Draw them twice!
			rand(2..6).times do
				obj7.pos(e.x + rand(0..20), e.y + rand(0..20))
				obj8.pos(e.x + rand(0..20), e.y + rand(0..20))
				obj9.pos(e.x + rand(0..20), e.y + rand(0..20))
			end
		end

		on :mouse_move do |e|
			obj7.pos(e.x, e.y) ; obj8.pos(e.x, e.y) ; obj9.pos(e.x, e.y)
		end

		update do
			# Method from class Particles: def draw(down=false, right=false, left=false)
			obj1.draw true ; obj2.draw	; obj3.draw(false, true)
			obj4.draw(true, false, true)	; obj5.draw(true, true)
			obj6.draw(false, false, true)

			obj7.draw ; obj8.draw(true, true) ; obj9.draw(true, false, true)
			obj10.draw(false, true) ; obj11.draw(false, false, true) ; obj12.draw(false, true)

			# Animate the message and greeting text!
			message.opacity -= 0.01 unless message.opacity < 0
			greeting.opacity -= 0.01 unless message.opacity < 0

			# Make it faster for a while, increment by 3, and then 1
			message.x += 3 unless message.x >= $width - message.width
			greeting.x -= 3 unless greeting.x < 0

			message.x += 1 unless message.x >= $width
			greeting.x -= 1 unless greeting.x < -greeting.width

			tm.text = p.call('%T:%N')[0..10]

			# A higher sleep will make the smooth animations to stutter, but will also reduce the CPU usage significantly
			sleep 0.01

			# boxes is a Boolean object, that controls when to show which squares!
			unless boxes
				obj10.pos(rand(0..$width), rand($height - 100..$height - 30))
				obj11.pos(rand(0..$width), rand($height - 50..$height))
				obj12.pos(rand(0..$width), $height)
			end

			# Every second do the following (to reduce the CPU usage). Updating them faster than this, is not required...
			if time.next == p.call('%s')
				qd.color = $colours.rotate![0]
				date.text, day.text = p.call('%D'), p.call('%A')
				boxes = false if time.to_i % 7 == 0
				if time.to_i % 2 == 0 and boxes then obj1.change ; obj2.change ; end
				if boxes then obj3.change ; obj4.change ; end
				obj5.change if time.to_i % 3 == 0 and boxes
				obj6.change if boxes
				boxes = true if time.to_i %  5 == 0
			end

			# Change the time to ensure that the above condition works correctly
			time = p.call('%s')
		end	# End of update block
		show
	end		# End of main method block
main			# Call the above main method
end			# End of begin, rescue, else block
