#!/usr/bin/env ruby
# Created by Sourav Goswami, thanks a lot to ruby2d! Made on GNU/Linux 64 bit OS...
# Change the fonts if it doesn't suit you!
# I wanted to make all in a single file to keep things simple. No other files, all included in Ruby2D.
#
# TIPS: Change the <textfont = path + (Dir.entries path).sample> with your font if the program crashes

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
		def initialize(hash) @hash = hash end
		def self.square() Square.new x: rand(0..$width) ,y: rand(0..$height), size: rand(10..40), color: 'random', z: 1 end
		def draw(down=false, right=false, left=false)
			@hash.values.each { |n|
				if down then n.y += 1 ; else n.y -= 1 end
				n.x += 1 if right
				n.x -= 1 if left
				n.opacity -= rand(0.005..0.01)	}
		end
		def alpha(obj, magical=false)
			obj.opacity = rand(0.2..1) if obj.opacity <= 0.1 and !magical
			obj.opacity = rand(0.1..0.5) if obj.opacity < 0.1 and magical
		end

		# Change the position of particles, randomly
		def change
			@hash.values.each do |n|
				n.y=  rand(0..$height) if n.y <= 0 or n.y >= $height
				n.x = rand(0..$width) if n.x <= 0 or n.x >= $width
				alpha(n)
			end
		end
		def fade(x, y) @hash.values.each { |val| if val.contains?(x, y) then val.opacity -= 0.5 end } end
	end

	class MagicParticles < Particles
		attr_reader :hash
		def initialize(hash) @hash = hash end
		def self.square(fizz=false)
			size = rand(8..12) unless fizz
			size = rand(10..15) if fizz
			colour = %w(yellow white lime orange) unless fizz
			colour = 'white' if fizz
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
		all_colours = %w(#3ce3b5 fuchsia orange blue green red yellow #E58AE8 #EB65BB white)
		$colours, colour = [], []
		until colour.length == 4 do colour << all_colours.delete(all_colours.sample) end
		colour.permutation { |i| $colours << i }

		path = "#{ENV['HOME']}/.local/share/fonts/"	# User's home directory
		textfont = path + (Dir.entries path).sample
		# Works nice with textfont = path + "ArimaKoshi-Bold.otf"	# You can use your favourite font too!
		puts "Using #{textfont} font"
		p = Proc.new { |f| Time.new.strftime(f) }
		time, boxes = p.call('%s'), true
		set title: "Clock", width: 640, height: 480, resizable: true

		# Some hardcoded values works for 640x480 resolution. The look won't change if you resize the window
		date = Text.new x: 185, y: 80, font: textfont, size: 60, text: p.call('%D'), z: 2
		tm = Text.new x: 160, y: 180, font: textfont, size: 60, text: p.call('%T:%N'), z: 2
		day  = Text.new x: 200, y: 280, font: textfont, size: 60, text: p.call('%A'), z: 2
		message = Text.new x: 170, y: 380, font: textfont, size: 30, text: p.call('%c'), z: 1
		greeting = Text.new x: 180, y: 30, font: textfont, size: 40, text: "Hello!", z: 1
		qd = Quad.new x2: $width, x3: $width, y3: $height, y4: $height, color: $colours.sample

		h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, s = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, Particles
		for i in 1..rand(5..7) do
			h1.merge! "sq#{i}": s.square ; h2.merge! "sq#{i}": s.square
			h3.merge! "sq#{i}": s.square ; h4.merge! "sq#{i}": s.square
			h5.merge! "sq#{i}": s.square ; h6.merge! "sq#{i}": s.square
		end
		# Hashes are passed to Particles, and assigned to obj1 to obj12. This will help to use the draw, change, and pos  methods
		obj1, obj2, obj3, obj4, obj5, obj6 = s.new(h1), s.new(h2), s.new(h3), s.new(h4), s.new(h5), s.new(h6)

		s = MagicParticles
		for i in 1..15
			h7.merge! "sq#{i}": s.square ; h8.merge! "sq#{i}": s.square
			h9.merge! "sq#{i}": s.square ; h10.merge! "sq#{i}": s.square(true)
			h11.merge! "sq#{i}": s.square(true) ; h12.merge! "sq#{i}": s.square(true)
		end
		obj7, obj8, obj9, obj10, obj11, obj12 = s.new(h7), s.new(h8), s.new(h9), s.new(h10), s.new(h11), s.new(h12)

		on :mouse_down do  |e|
			qd.color = $colours.rotate![0]
			obj1.change ; obj2.change
			boxes = true

			# Show the Good Morning etc. messages, and also a proper 12H time format when the mouse is pressed
			message.text = p.call('%a, %b %d, %I:%M %p')
			message.x, greeting.x = 170, 180
			message.y, greeting.y = 380, 30
			message.opacity = greeting.opacity = 1

			# Get the current time in 1..23 hour format, required just below!
			t = p.call('%H').to_i
			if t >=  5 and t < 12 then greeting.text = "Good Morning!..."
			elsif t >=  12 and t < 16 then greeting.text = "Good Afternoon."
			elsif t >=  16 and t < 19 then greeting.text = "Good Evening!!..."
			else greeting.text = "Very Good Night" end
			20.times do
				obj10.pos(rand(0..100), rand(0..$height))
				obj11.pos(rand($width - 100..$width), rand(0..$height))
			end
			rand(2..6).times do
				obj7.pos(e.x + rand(0..20), e.y + rand(0..20))
				obj8.pos(e.x + rand(0..20), e.y + rand(0..20))
				obj9.pos(e.x + rand(0..20), e.y + rand(0..20))
			end
		end

		on :mouse_move do |e|
			obj7.pos(e.x, e.y) ; obj8.pos(e.x, e.y) ; obj9.pos(e.x, e.y)
			obj1.fade(e.x, e.y) ; obj2.fade(e.x, e.y) ; obj3.fade(e.x, e.y)
			obj4.fade(e.x, e.y) ; obj5.fade(e.x, e.y) ; obj6.fade(e.x, e.y)
		end

		update do
			# Method from class Particles: def draw(down=false, right=false, left=false)
			obj1.draw true ; obj2.draw ; obj3.draw(false, true)
			obj4.draw(true, false, true) ; obj5.draw(true, true) ; obj6.draw(false, false, true)
			obj7.draw ; obj8.draw(true, true) ; obj9.draw(true, false, true)
			obj10.draw(false, true) ; obj11.draw(false, false, true) ; obj12.draw(false, true)

			# Animate the message and greeting text!
			message.opacity -= 0.01 unless message.opacity < 0
			greeting.opacity -= 0.01 unless message.opacity < 0

			message.x += 3 unless message.x >= $width - message.width
			greeting.x -= 3 unless greeting.x < 0
			message.x += 1 unless message.x >= $width
			greeting.x -= 1 unless greeting.x < -greeting.width

			tm.text = p.call('%T:%N')[0..10]
			unless boxes
				obj10.pos(rand(0..$width), rand($height - 100..$height - 30))
				obj11.pos(rand(0..$width), rand($height - 50..$height))
				obj12.pos(rand(0..$width), $height)
			end

			# Do the following every second. Updating them any faster is not required...
			if time.next == p.call('%s')
				date.text, day.text = p.call('%D'), p.call('%A')
				boxes = false if time.to_i % 7 == 0
				if time.to_i % 2 == 0 and boxes then obj1.change ; obj2.change end
				if boxes then obj3.change ; obj4.change end
				obj5.change if time.to_i % 3 == 0 and boxes
				obj6.change if boxes
				boxes = true if time.to_i %  5 == 0
			end
			time = p.call('%s')	# Change the time to ensure that the above condition works correctly
		end
	end
	main
	show
end
