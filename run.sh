#!/bin/bash

# g++ -std=c++11 \
# -I/usr/local/include/opencv4 \
# -L/usr/local/lib/opencv4 \
# -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -lopencv_objdetect -lopencv_features2d \
# akaze.cpp

g++ -std=c++11 \
-I/usr/local/include/opencv4 \
-L/usr/local/lib/opencv4 \
-lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -lopencv_objdetect -lopencv_features2d \
cp.cpp

# ./a.out -d=0
# ./a.out -d=1
# ./a.out -d=2

name = "orb"
for seed in $(seq 1 15)
	do
		echo $seed
		./a.out -d=0 -r >> ${name}.csv
	done
cat ${name}.csv