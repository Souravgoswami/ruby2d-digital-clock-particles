#!/usr/bin/env ruby
# Created by Sourav Goswami, thanks to ruby2d
begin
	require 'ruby2d'
rescue LoadError => err
	puts "An error occured:\n\t#{err}\nThat means Ruby2D is not yet installed :("
	abort "For more info, visit:\033[1;34m http://www.ruby2d.com/learn/get-started/"
else
	class Particles
		attr_accessor :hash, :square
		def initialize(hash)
			@hash = hash
		end

		def self.square(special=false, fizz=false)
			extend Ruby2D::DSL
			size = rand(10..50) unless special
			size = rand(10..15) if special
			colour = $colours.sample unless special
			if special
				magical_colours = %w(yellow white blue #ff50a6 #3ce3b4)
				colour = []
				until colour.length == 4 do colour << magical_colours.delete(magical_colours.sample) ; end
			end

			colour = 'white' if fizz
			z = 1 unless special
			z = -1 if special
			Square.new x: rand(0..$width) ,y: rand(0..$height), size: size,
				color: colour, z: z
		end

		def alpha(obj, magical=false)
			obj.opacity = rand(0.2..1) if obj.opacity <= 0.1 and !magical
			obj.opacity = rand(0.1..0.5) if obj.opacity < 0.1 and magical
		end

		def draw(down=false, right=false, left=false)
			@hash.values.each { |n| if down then n.y += 1 ; else n.y -= 1 end
				n.x += 1 if right
				n.x -= 1 if left
				n.opacity -= rand(0.005..0.01)
		}
		end

		def change
			@hash.values.each do |n|
				n.y=  rand(0..$height) if n.y <= 0 or n.y >= $height
				n.x = rand(0..$width) if n.x <= 0 or n.x >= $width
				alpha(n)
			end
		end

		def pos(posx, posy)
				object = @hash.values.sample
				object.x, object.y, object.z = posx, posy, 1
				self.alpha(object, true)
				self.draw
		end
	end

	def main()
		$width, $height = 640, 480
		all_colours = %w(#3ce3b5 fuchsia orange blue white green red #E58AE8 #EB65BB #FFFFFF)
		colour = []
		until colour.length == 4 do colour << all_colours.delete(all_colours.sample) ; end
		$colours = []
		colour.permutation { |i| $colours << i }

		path = "#{ENV['HOME']}/.local/share/fonts/"
		textfont = path + (Dir.entries path).sample
		textfont = path + "ArimaKoshi-Bold.otf"
		puts "Using #{textfont} font"

		p = Proc.new { |f| Time.new.strftime(f) }
		time, boxes = p.call('%s'), true

		set title: "Clock", width: 640, height: 480, resizable: true

		date = Text.new x: 185, y: 80, font: textfont, size: 60, text: p.call('%D'), z: 2
		tm = Text.new x: 160, y: 180, font: textfont, size: 60, text: p.call('%T:%N'), z: 2
		day  = Text.new x: 200, y: 280, font: textfont, size: 60, text: p.call('%A'), z: 2
		message = Text.new x: 170, y: 380, font: textfont, size: 30, text: p.call('%c'), z: 0
		greeting = Text.new x: 180, y: 30, font: textfont, size: 40, text: "Hello!", z: 0
		qd = Quad.new x2: $width, x3: $width, y3: $height, y4: $height, color: $colours.sample

		h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, s = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, Particles
		for i in 1..rand(4..8) do
			h1.merge! "sq#{i}": s.square ; h2.merge! "sq#{i}": s.square
			h3.merge! "sq#{i}": s.square ; h4.merge! "sq#{i}": s.square
			h5.merge! "sq#{i}": s.square ; h6.merge! "sq#{i}": s.square
		end

		for i in 1..20
			h7.merge! "sq#{i}": s.square(true)
			h8.merge! "sq#{i}": s.square(true)
			h9.merge! "sq#{i}": s.square(true)
			h10.merge! "sq#{i}": s.square(true, true)
			h11.merge! "sq#{i}": s.square(true, true)
			h12.merge! "sq#{i}": s.square(true, true)
		end

		obj1, obj2, obj3 = Particles.new(h1), Particles.new(h2), Particles.new(h3)
		obj4, obj5, obj6 = Particles.new(h4), Particles.new(h5), Particles.new(h6)
		obj7, obj8, obj9 = Particles.new(h7), Particles.new(h8), Particles.new(h9)
		obj10, obj11, obj12 = Particles.new(h10), Particles.new(h11), Particles.new(h12)

		on :mouse_down do  |e|
			qd.color = $colours.rotate![1]
			obj1.change
			obj2.change
			t = p.call('%H').to_i

			message.text = p.call('%a, %b %d, %I:%M %p')
			message.z = greeting.z = 2
			message.x, greeting.x = 170, 180
			message.y, greeting.y = 380, 30
			message.opacity = greeting.opacity = 1

			if t >=  5 and t < 12 then greeting.text = "Good Morning!..."
			elsif t >=  12 and t < 16 then greeting.text = "Good Afternoon."
			elsif t >=  16 and t < 19 then greeting.text = "Good Evening!!..."
			else greeting.text = "Very Good Night" ; end
			20.times do
				obj10.pos(rand(0..100), rand(0..$height))
				obj11.pos(rand(-100..$width), rand(0..$height))
			end
			boxes = true
		end

		on :mouse_move do |e|
			obj7.pos(e.x, e.y)
			obj8.pos(e.x, e.y)
			obj9.pos(e.x, e.y)
		end

		update do
			obj1.draw true
			obj2.draw
			obj3.draw(false, true)
			obj4.draw(true, false, true)
			obj5.draw(true, true)
			obj6.draw(false, false, true)
			obj7.draw
			obj8.draw(true, true, false)
			obj9.draw(true, false, true)
			obj10.draw(false, true)
			obj11.draw(false, false, true)
			obj12.draw(false, true, false)

			message.opacity -= 0.01 unless message.opacity < 0
			greeting.opacity -= 0.01 unless message.opacity < 0

			message.x += 3 unless message.x >= $width - message.width
			greeting.x -= 3 unless greeting.x < 0

			message.x += 1 unless message.x >= $width
			greeting.x -= 1 unless greeting.x < -greeting.width

			tm.text = p.call('%T:%N')[0..10]
			sleep 0.01

			unless boxes
				obj10.pos(rand(0..$width), $height)
				obj11.pos(rand(0..$width), $height)
				obj12.pos(rand(0..$width), $height)
			end

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

			time = p.call('%s')
		end
		show
	end
main
end
