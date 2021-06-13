// https://docs.opencv.org/master/db/d70/tutorial_akaze_matching.html
// https://docs.opencv.org/master/dc/d16/tutorial_akaze_tracking.html
// https://docs.opencv.org/master/d9/df8/tutorial_root.html
// https://docs.opencv.org/master/d9/d97/tutorial_table_of_content_features2d.html
// https://github.com/opencv/opencv/blob/master/samples/cpp/tutorial_code/features2D/AKAZE_match.cpp
// https://docs.opencv.org/4.5.2/dc/dc3/tutorial_py_matcher.html

// $ brew list --versions | grep -i opencv
// opencv 4.5.2 on Mac


// https://pystyle.info/opencv-feature-matching/
// http://poly.hatenablog.com/entry/2014/01/06/063012
// http://independence-sys.net/main/?p=2632

#include <opencv2/features2d.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>

using namespace std;
using namespace cv;

const float inlier_threshold = 2.5f; // Distance threshold to identify inliers with homography check
const float nn_match_ratio = 0.8f;   // Nearest neighbor matching ratio

int main(int argc, char* argv[])
{
    //! [load]
    CommandLineParser parser(argc, argv,
                             "{@img1 | graf1.png | input image 1}"
                             "{@img2 | graf3.png | input image 2}"
                             "{@homography | H1to3p.xml | homography matrix}");
    Mat img1 = imread( samples::findFile( parser.get<String>("@img1") ), IMREAD_GRAYSCALE);
    Mat img2 = imread( samples::findFile( parser.get<String>("@img2") ), IMREAD_GRAYSCALE);

    Mat homography;
    FileStorage fs( samples::findFile( parser.get<String>("@homography") ), FileStorage::READ);
    fs.getFirstTopLevelNode() >> homography;
    //! [load]

    //! [AKAZE]
    vector<KeyPoint> kpts1, kpts2;
    Mat desc1, desc2;








    Ptr<AKAZE> akaze = AKAZE::create();
    akaze->detectAndCompute(img1, noArray(), kpts1, desc1);
    akaze->detectAndCompute(img2, noArray(), kpts2, desc2);
    //! [AKAZE]

    // // Initiate ORB detector
    // Ptr<ORB> orb = ORB::create();
    // // find the keypoints and descriptors with ORB
    // orb->detectAndCompute(img1, noArray(), kpts1, desc1);
    // orb->detectAndCompute(img2, noArray(), kpts2, desc2);
    //! [ORB]










    //! [2-nn matching]
    BFMatcher matcher(NORM_HAMMING);
    vector< vector<DMatch> > nn_matches;
    matcher.knnMatch(desc1, desc2, nn_matches, 2);
    //! [2-nn matching]

    //! [ratio test filtering]
    vector<KeyPoint> matched1, matched2;
    for(size_t i = 0; i < nn_matches.size(); i++) {
        DMatch first = nn_matches[i][0];
        float dist1 = nn_matches[i][0].distance;
        float dist2 = nn_matches[i][1].distance;

        if(dist1 < nn_match_ratio * dist2) {
            matched1.push_back(kpts1[first.queryIdx]);
            matched2.push_back(kpts2[first.trainIdx]);
        }
    }
    //! [ratio test filtering]

    //! [homography check]
    vector<DMatch> good_matches;
    vector<KeyPoint> inliers1, inliers2;
    for(size_t i = 0; i < matched1.size(); i++) {
        Mat col = Mat::ones(3, 1, CV_64F);
        col.at<double>(0) = matched1[i].pt.x;
        col.at<double>(1) = matched1[i].pt.y;

        col = homography * col;
        col /= col.at<double>(2);
        double dist = sqrt( pow(col.at<double>(0) - matched2[i].pt.x, 2) +
                            pow(col.at<double>(1) - matched2[i].pt.y, 2));

        if(dist < inlier_threshold) {
            int new_i = static_cast<int>(inliers1.size());
            inliers1.push_back(matched1[i]);
            inliers2.push_back(matched2[i]);
            good_matches.push_back(DMatch(new_i, new_i, 0));
        }
    }
    //! [homography check]

    //! [draw final matches]
    Mat res;
    drawMatches(img1, inliers1, img2, inliers2, good_matches, res);
    imwrite("akaze_result.png", res);

    double inlier_ratio = inliers1.size() / (double) matched1.size();
    cout << "A-KAZE Matching Results" << endl;
    cout << "*******************************" << endl;
    cout << "# Keypoints 1:                        \t" << kpts1.size() << endl;
    cout << "# Keypoints 2:                        \t" << kpts2.size() << endl;
    cout << "# Matches:                            \t" << matched1.size() << endl;
    cout << "# Inliers:                            \t" << inliers1.size() << endl;
    cout << "# Inliers Ratio:                      \t" << inlier_ratio << endl;
    cout << endl;

    imshow("result", res);
    waitKey();
    //! [draw final matches]

    return 0;
}