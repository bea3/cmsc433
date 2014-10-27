#!/usr/bin/env ruby

require 'getoptlong'

def validateArgs
	if ARGV.length != 0 and ARGV.length != 2
		puts "Invalid number of arguments"
		exit
	end
end

def getLogFile(arg)
	if ARGV.length == 0
		log = arg
	elsif ARGV.length == 2
		log = ARGV[1]
		displayNum = ARGV[0]
	end
	return log, displayNum
end

def getData(log)
	file = File.open(log, "r")
	$resourceCounts = Hash.new
	$errorsCounts = Hash.new
	$requestersCounts = Hash.new
	$hourly = Hash.new
	
	while (line = file.gets)
		if line =~ /([\d\w\.-]+) (-|) ([\w\d\.-]+)? (\[[\d\w\s\/]+)([:\d]+) ([-\d]+)\] "(GET|HEAD|PROPFIND|OPTIONS|POST) (.+) HTTP[\/\d\.\d]+" (\d+) ([\d-]+)/
			#gets information and counts them
			resource = $8
			statusCode = $9.to_i
			ip = $1
			hour = $5[1..2]
	
			if hour[0] == "0"
				hour = hour[1]
			end

			#counts resources
			if ! $resourceCounts.has_key?(resource)
				$resourceCounts[resource] = 1
			else
				$resourceCounts[resource] += 1
			end

			#counts errors
			if $errorsCounts.has_key?(resource)==false 
				if statusCode >= 400 and statusCode <= 500
					$errorsCounts[resource] = 1
				end
			elsif $errorsCounts.has_key?(resource)==true
				if statusCode >= 400 and statusCode <= 500
					$errorsCounts[resource] += 1
				end
			end

			#counts requesters (IP address)
			if ! $requestersCounts.has_key?(ip)
				$requestersCounts[ip] = 1
			else
				$requestersCounts[ip] += 1
			end

			#counts requests that come in hourly
			if ! $hourly.has_key?(hour)
				$hourly[hour] = 1
			else
				$hourly[hour] +=1
			end
		end
	end
end

def convertToArray

$resources = Array.new
$requesters = Array.new
$errors = Array.new
$hours = Array.new

#turn hash array to 2d array
for item in $resourceCounts
	tmp = [ item[0], item[1] ]
	$resources.push(tmp)
end
$resources.sort_by! {|x, y| [-y, x]}

for item in $requestersCounts
	tmp = [ item[0], item[1]]
	$requesters.push(tmp)
end 
$requesters.sort_by! {|x,y| [-y, x]}

for item in $errorsCounts
	tmp = [item[0], item[1]]
	$errors.push(tmp)
end
$errors.sort_by! {|x,y| [-y, x]}

for item in $hourly
	tmp = [ item[0], item[1]]
	$hours.push(tmp)
end


end

# START OF PROGRAM ----------------------------------------------


opts = GetoptLong.new(
	['--help', GetoptLong::NO_ARGUMENT],
	['--resources', GetoptLong::REQUIRED_ARGUMENT],
	['--requesters', GetoptLong::REQUIRED_ARGUMENT],
	['--errors', GetoptLong::REQUIRED_ARGUMENT],
	['--hourly', GetoptLong::REQUIRED_ARGUMENT],
	['--number','-n', GetoptLong::REQUIRED_ARGUMENT]
)

opts.each do |opt, arg|
case opt 
	when "--help"
	puts <<END_OF_STRING
	--resources: Counts/displays how times each resources has been requested; sorted by count in descending order, then alphabetically
	--requesters: Counts/displays how many times each source IP has requested a resource; sorted by count in ascending order, then by IP address
	--errors: Counts/displays counts how many times each resource has been requested (only HTTP status codes in 400s or 500s); sorted by count in descending order, then alphabetically
	--hourly: Counts requests that come in each hour (0-23) and report the total number of requests within each hour block, sorted by hour

	each command has an option -n/--number, which limits the number of records to display
END_OF_STRING
	
	when "--resources"
	validateArgs
	log, displayNum = getLogFile(arg)
	getData(log)
	convertToArray
	counter = 0
	if displayNum != nil
		while counter <= displayNum.to_i
			printf "%8d    %s\n", $resources[counter][1], $resources[counter][0]
			counter += 1
		end
	else
		$resources.each do |elem|
			printf "%8d    %s\n", elem[1], elem[0]
		end
	end

	when "--requesters"			#DONE
	validateArgs
	log, displayNum = getLogFile(arg)
	getData(log)
	convertToArray
	counter = 0
	if displayNum != nil
		while counter <= displayNum.to_i
			printf "%8d    %s\n", $requesters[counter][1], $requesters[counter][0]
			counter += 1
		end
	else
		$requesters.each do |elem|
			printf "%8d    %s\n", elem[1], elem[0]
		end
	end

	when "--errors"			#DONE
	validateArgs
	log, displayNum = getLogFile(arg)
	getData(log)
	convertToArray
	counter = 0
	if displayNum != nil
		while counter <= displayNum.to_i
			printf "%8d    %s\n", $errors[counter][1], $errors[counter][0]
			counter += 1
		end
	else
		$errors.each do |elem|
			printf "%8d    %s\n", elem[1], elem[0]
		end
	end

	when "--hourly"			#DONE
	validateArgs
	log, displayNum = getLogFile(arg)
	getData(log)
	convertToArray	
	counter = 0
	if displayNum != nil
		while counter <= displayNum.to_i
			printf "%11s:00    %s\n", $hours[counter][0], $hours[counter][1]
			counter += 1
		end
	else
		$hourly.sort{|a,b| b[0]<=>b[0]}.each { |elem| printf "%11s:00    %s\n", elem[0], elem[1]}
	end
	
	end	#closes case statement
end
