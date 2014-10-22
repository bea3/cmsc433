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
        if line =~ /#(?<!^)(\h{6}|\h{3})/
		 colors=line.scan(/(?<=#)(?<!^)(\h{6}|\h{3})\W/)
		 for item in colors
			color = item[0]
			color.downcase!
			if color.length == 3
				#rgb -> rrggbb
				tmpColorArr = color.split("")
				firstColor = tmpColorArr[0]
				secondColor = tmpColorArr[1]
				thirdColor = tmpColorArr[2]
				color = firstColor+firstColor+secondColor+secondColor+thirdColor+thirdColor
			end
			if colorArr.has_value?(color) == false
				arrayLength = colorArr.length
				colorArr[arrayLength] = color
				occArr[arrayLength] = 1
			else
				index = colorArr.key(color)
				occArr[index] += 1
			end
		 end
				
	end
end

puts "color array"
puts colorArr
puts "occurences"
puts occArr.join(", ")

file.close

# EDIT HTML -----------------------------------------------------
