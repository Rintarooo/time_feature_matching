#!/bin/bash

if [ -f tmp.txt ]; then
	rm tmp.txt
	echo "rm tmp.txt"
fi
if [ -f o.txt ]; then
	rm o.txt
	echo "rm o.txt"
fi
if [ -f o.csv ]; then
	rm o.csv
	echo "rm o.csv"
fi
		
if [ "$1" = "cpp" ]; then
	echo "g++ -std=c++11 \
	-I/usr/local/include/opencv4 \
	-L/usr/local/lib/opencv4 \
	-lopencv_core -lopencv_imgcodecs -lopencv_objdetect -lopencv_imgproc -lopencv_ml \
	svm.cpp"
	g++ -std=c++11 \
	-I/usr/local/include/opencv4 \
	-L/usr/local/lib/opencv4 \
	-lopencv_core -lopencv_imgcodecs -lopencv_objdetect -lopencv_imgproc -lopencv_ml \
	svm.cpp
	
	for seed in $(seq 1 30)
	do
		# zsh built-in command "time" outputs measured time as error
		(time ./a.out) 2>> tmp.txt
	done
elif [ "$1" = "py" ]; then
	for seed in $(seq 1 30)
	do
		(time python svm.py) 2>> tmp.txt
	done
else
	echo "${0} cpp or ${0} py"
	exit 1
fi

# output lines where sequences match "user" in tmp.txt
grep "user" tmp.txt > o.txt

# about sed command
# https://qiita.com/takech9203/items/b96eff5773ce9d9cc9b3
echo "execution time" > "$1".csv
# "user	0m" in the head of a line -> delete, "s" in the end of a line -> delete
cat o.txt | sed -e "s/^user	0m//" -e "s/s\$//" >> "$1".csv
echo "cat ${1}.csv"
cat "$1".csv