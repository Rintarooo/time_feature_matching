#!/bin/bash

rm -rf a.out

g++ -std=c++11 \
-I/usr/local/include/opencv4 \
-L/usr/local/lib/opencv4 \
-lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -lopencv_objdetect -lopencv_features2d \
main.cpp

# ./a.out -d=orb
# ./a.out -d=akaze
# ./a.out -d=brisk


# name="orb"
iter=100
for name in "orb" "akaze" "brisk"
	do
	rm -rf ${name}.csv
	echo "create ${name}.csv"
	for seed in $(seq 1 ${iter})
		do
			echo $seed
			./a.out -d=${name} -p >> ${name}.csv
		done
	echo "cat ${name}.csv"
	cat ${name}.csv	
	done
