#include "opencv2/opencv.hpp"
using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
    Mat aa =imread("../in.jpg");
    double scale = 0.20;
    Size dsize = Size(aa.cols*scale, aa.rows*scale);
    Mat bb;
    resize(aa,bb,dsize);
    imshow("bb",bb);

    waitKey(0);
//    VideoCapture capture(0);
//    while (1)
//    {
//        Mat frame;
//        capture >> frame;
//        imshow("CameraRead", frame);
//        waitKey(30);
//    }
//    return 0;
}