#!/usr/bin/env ruby

require 'getoptlong'

def validateArgs
	if ARGV.length != 0 and ARGV.length != 2
		puts "Invalid number of arguments"
	end
end

def getData
	file = File.open($log, "r")
	resourceCounts = Hash.new
	while (line = file.gets)
		if line =~ /([\d\.]+) (-|) ([\w\d\.-]+)? (\[[\d\w\s\/:-]+\]) "GET (.+) HTTP[\w\/\d\.\d]+" (\d+) ([\d-]+)/
			#gets resources and counts them
			resource = $5
			if ! resourceCounts.has_key?(resource)
				resourceCounts[resource] = 1
			else
				resourceCounts[resource] += 1
			end
		end
	end
	
	puts "LENGTH: #{resourceCounts.length}"
 	resourceCounts.sort{|a,b| b[1]<=>a[1]}.each { |elem| printf "%8d   %s\n", elem[1], elem[0]}
end

def getLogFile(arg)
	if ARGV.length == 0
		$log = arg
	elsif ARGV.length == 2
		$log = ARGV[1]
	end
end

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
	getLogFile(arg)
	getData
	when "--requesters"
	validateArgs
	getLogFile(arg)
	when "--errors"
	validateArgs
	getLogFile(arg)
	when "--hourly"
	validateArgs
	getLogFile(arg)
	end
end

