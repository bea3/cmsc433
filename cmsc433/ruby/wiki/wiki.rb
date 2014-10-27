#!/usr/bin/env ruby

if ARGV.length != 3 and ARGV.length != 4
	puts "Invalid number of arguments"
	exit
else ARGV.length == 3 or ARGV.length == 4
	$topic = ARGV[0]
	$distance = ARGV[1]
	$branchFactor = ARGV[2]
	ARGV.length == 4 ? $wikiURL = ARGV[3] : $wikiURL = nil
end

if $branchFactor < 0 or $distance < 0:
	puts "Distance and/or branching factor cannot be a negative number"
	exit
end

def searchProcess


end
