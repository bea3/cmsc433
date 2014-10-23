#!/usr/bin/env ruby

require 'open-uri'

def hexToDec(hexNum)
	hexArr = hexNum.split("")
	hexArr.reverse!
	sum = 0
	i = 0
	while i < hexArr.length
		digit = hexArr[i]
		case digit
		when "a" 
			digit = 10	
		when "b" 
			digit = 11
		when "c" 
			digit = 12
		when "d" 
			digit = 13
		when "e" 
			digit = 14
		when "f" 
			digit = 15
		else digit = hexArr[i].to_i
		end
		sum += (digit * (16**i))
		i += 1
	end
	return sum
end

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

outputFile = File.open(output, 'w+')

#COLOR EXTRACTION------------------------------------------------
file = open(src)

colorArr = Hash.new
occArr = Array.new

while (line = file.gets)
        if line =~ /#(?<!^)(\h{6}|\h{3})/
		 colors=line.scan(/\W(?<=#)(?<!^)(\h{6}|\h{3})\W/)
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

=begin
puts "color array"
puts colorArr
puts "occurences"
puts occArr.join(", ")
=end

# EDIT HTML -----------------------------------------------------

firstpart = <<END_OF_STRING
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <title>Stylesheet Colors</title>
    <style>
      body {
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        color: #333;
      }
      h1 {
        font-size: 40px;
        font-weight: 300;
        margin: 36px 8px 8px 8px;
        color: #333;
      }
      h2 {
        margin: 0 8px 20px 8px;
        font-size: 18px;
        font-weight: 300;
      }
      h2 a {
        color: #999 !important;
        text-decoration: none;
      }
      h2 a:hover {
        text-decoration: underline;
      }
      .color { 
        height: 200px;
        width: 200px;
        float: left;
        margin: 10px;
        border: 1px solid #000; 
        position: relative;
        -webkit-box-shadow: 0 0 10px #eee; 
        -moz-box-shadow: 0 0 10px #eee; 
        box-shadow: 0 0 10px #eee; 
      }
      .color:hover {
        -webkit-box-shadow: 0 0 10px #666; 
        -moz-box-shadow: 0 0 10px #666; 
        box-shadow: 0 0 10px #666; 
      }
      .info { 
        background-color: #fff;
        background-color: rgba(255,255,255,.5);
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        padding: 5px;
        border-top: 1px solid #000;
        font-size: 12px;
        text-align: right;
      }
      .rgb {
        float: left;
      }
    </style>
  </head>
  <body>
    <h1>Stylesheet Colors</h1>
END_OF_STRING

outputFile.write(firstpart)

linkToSrc = '    <h2><a href="CHANGE_THIS">CHANGE_THIS</a></h2>'
linkToSrc.gsub!(/CHANGE_THIS/, src)
outputFile.write(linkToSrc)

swatchStr = <<END_OF_STRING
 <div class="color" style="background-color: #HEXNUM">
  <div class="info">
    <div class="rgb">
      RGB: DECNUMR, DECNUMG, DECNUMB
    </div>
    <div class="hex">
      Hex: #HEXNUM
    </div>
    <!-- OCCNUM occurrence(s) -->
  </div>
</div>
END_OF_STRING

i = 0
while i < colorArr.length
	color = colorArr[i]
	occurence = occArr[i]
	swatch = String.new(swatchStr)
	swatch.gsub!(/HEXNUM/, color)

	color = color.split("")
	hexR = color[0]+color[1]
	hexG = color[2]+color[3]
	hexB = color[4]+color[5]

	decR = hexToDec(hexR)
	decG = hexToDec(hexG)
	decB = hexToDec(hexB)

	swatch.gsub!(/DECNUMR/,decR.to_s)
	swatch.gsub!(/DECNUMG/,decG.to_s)
	swatch.gsub!(/DECNUMB/,decB.to_s)
	swatch.gsub!(/OCCNUM/,occurence.to_s)
	outputFile.write(swatch)

	i += 1
end

lastpart = <<END_OF_STRING
 </body>
</html>
END_OF_STRING

outputFile.write(lastpart)
file.close
outputFile.close
