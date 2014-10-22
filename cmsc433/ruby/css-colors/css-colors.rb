#!/usr/bin/env ruby

require 'open-uri'

#GETS INPUT AND VALIDATES----------------------------------------
if ARGV.length != 2
        puts "Incorrect number of arguments"
        exit 1
end

src = ARGV[0]
output = ARGV[1]

srcExtension = File.extname(src)
if srcExtension != ".css"
        puts "Input file is not a CSS file"
        exit 1
end

srcExtension = File.extname(output)
filename = File.basename(output, '.*') + ".html"

File.open(filename, 'w+')

#COLOR EXTRACTION------------------------------------------------

file = open(src)

colorArr = Hash.new
occArr = Array.new

while (line = file.gets)
#line = File.readlines(file)[2]
#puts "line: " + line.to_s
#puts "---------------------"
        if line =~ /(?<=#)(?<!^)(\h{6}|\h{3})/
		 colors=line.scan(/(?<=#)(?<!^)(\h{6}|\h{3})/)
		 for item in colors
			color = item[0]
			if color.length == 3
				//convert from rgb to rrggbb
			if colorArr.has_value?(color) == false
				arrayLength = colorArr.length
				colorArr[arrayLength] = color
				puts color + " was added to the colorArr"
				occArr[arrayLength] = 1
			else
				index = colorArr.key(color)
				occArr[index] += 1
				puts "Already was a color, incremented occurence"
			end
		 end
				
	end
end

puts "color array"
puts colorArr
puts "occurences"
occArr.each do |occ|
	puts occ.join(", ")
end

file.close
