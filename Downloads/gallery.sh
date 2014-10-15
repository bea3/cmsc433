#!/bin/bash

#setting up arguments
tempFile=$1
dataFile=$2
picsDir=$3
destDir=$4

counter=0

#create directory, delete stuff in it if it already exits
if [ -d $destDir ]; then
        read -p "The directory exists. Would you like to delete its contents? (yes/no) " answer
        
        if [ "$answer" = "yes" ]; then
                rm $destDir/*
        elif [ "$answer" = "no" ]; then
		echo "Okay."
		exit
	else
		echo "Invalid input."
		exit
	fi
else
        mkdir -p $destDir
fi

#-----------------------------------------------------

title=""
description=""

while read line
do
	key=""
	value=""
        [ -z "$line" ] && continue
	IFS=":"
	read key value <<< "$line"

	key=$(echo "${key}" | sed -e 's/^[ \t]*//')
	value=$(echo "${value}" | sed -e 's/^[ \t]*//')

	if [ "$key" = "title" ]; then
		title=$value
		#trim title
	elif [ "$key" = "description" ]; then
		description=$value
		#trim description
	fi
	
done  < $dataFile

echo "Creating HTML"

sed -i.orig -e "s/{{title}}/$title/" $tempFile
sed -i.orig -e "s/{{description}}/$description/" $tempFile

#----------------------------------------------------
#get all the images and put it into the destination directory
find $picsDir/ -name "*.jpg" -exec cp {} $destDir \;
find $picsDir/ -name "*.jpeg" -exec cp {} $destDir \;

thumbnails=()
pics=$(find $destDir -name "*.jpg" -or -name "*.jpeg")
readarray -t allPics <<< "$pics"

#make thumbnail images of all the images
for x in ${allPics[*]}
do
	filename=$(basename $x)
	nameLength=$(expr length $filename)
	nameLength=$(($nameLength-4))
	filename=${filename:0:nameLength}
	echo "Creating thumbnail for $filename"
	thumbnailFileName="$destDir$filename-thumb.jpg"
	
	convert -define jpeg:size=500x180 $x -auto-orient \
		-thumbnail 250x90 -unsharp 0x.5 $thumbnailFileName
done

#----------------------------------------------------

pattern=$(sed -n '/{{#each photos}}/,/{{\/each}}/p' $tempFile > pattern.txt)
sed -i -e "s/{{#each photos}}//" pattern.txt
sed -i -e "s/{{\/each}}//" pattern.txt
replacement=""
while read line
do
	key=""
	value=""
	photoName=""
	caption=""
	thumbnail=""
        [ -z "$line" ] && continue
	IFS=":"
	read photoName caption <<< "$line"
	
	photoName=$(echo "${photoName}" | sed -e 's/^[ \t]*//')
	caption=$(echo "${caption}" | sed -e 's/^[ \t]*//')
	last3Chars=${photoName:(-4)}
	if [ "$last3Chars" = ".jpg" ]; then
		nameLength=$(expr length $photoName)
		nameLength=$(($nameLength-4))
		nameOnly=${photoName:0:nameLength}
		thumbnail="$nameOnly-thumb.jpg"
	fi
	counter=$((counter+1))
	line=$(sed -e "s/{{thumb}}/$thumbnail/" -e "s/{{caption}}/$caption/g" -e "s/{{full}}/$photoName/" pattern.txt)
	replacement="$replacement\n$line"
done < $dataFile

for x in ${allPics[*]}
do
	filename=$(basename $x)
	nameLength=$(expr length $filename)
	if [ $nameLength -gt 10 ]; then
		nameLength=$(($nameLength-10))	
		testName=${filename:0:nameLength}
	fi
		testName=$filename
		photoName=$filename
		echo "" > grep.txt
		grep $filename $dataFile > grep.txt
		if [ ! -s grep.txt -a "$testName" != "-thumb.jpg" ]; then
			echo "" > grep.txt
			nameLength=$(expr length $filename)
			nameLength=$(($nameLength-4))
			filename=${filename:0:nameLength}
			thumbnail="$filename-thumb.jpg"
			emptyStr=""
			counter=$((counter+1))
			line=$(sed -e "s/{{thumb}}/$thumbnail/" -e "s/{{caption}}/$emptyStr/g" -e "s/{{full}}/$photoName/" pattern.txt)
			replacement="$replacement\n$line"
		fi
done

echo -e "$replacement" > replacement.txt

beginning=$( sed -n '/<!DOCTYPE HTML>/,/{{#each photos}}/p' $tempFile  > beginning.txt)
sed -i -e "s/{{#each photos}}//" beginning.txt
end=$(sed -n '/{{\/each}}/,$p' $tempFile > end.txt)
sed -i -e "s/{{\/each}}//" end.txt
cat beginning.txt replacement.txt end.txt > index.html

mv index.html $destDir
