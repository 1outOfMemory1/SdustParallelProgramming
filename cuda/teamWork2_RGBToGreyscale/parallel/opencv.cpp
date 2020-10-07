#include "opencv2/opencv.hpp"
using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
    VideoCapture capture(0);
    while (1)
    {
        Mat frame;
        capture >> frame;
        imshow("CameraRead", frame);
        waitKey(30);
    }
    return 0;
}