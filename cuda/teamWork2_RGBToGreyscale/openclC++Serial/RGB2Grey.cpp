#include "opencv2/core.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/videoio.hpp"
#include <iostream>


// clion 版本

using namespace cv;
using namespace std;
int main(int argc,char * argv[]){
    double seconds;
    double allSeconds;
    clock_t all_begin_time = clock();
    string filePath = "in.jpg";
    string fileName = "";
    if(argc > 1){
        filePath = argv[1];
        cout<<"already input value,picture file path is "<<filePath<<endl;
    }else{
        cout<<"no input value found,default picture file path is "<<filePath<<endl;
    }
    int i=filePath.size()-1;
    for(;i>=0;i--){
        if(filePath[i] == '/'){
            fileName = filePath.substr(i+1,filePath.size());
            break;
        }
    }
    if(i <= 0)
        fileName = filePath;

    Mat src= imread(filePath);
    if(src.empty()){
        cout<<"input picture not found, please check your path"<<endl;
        exit(-1);
    }
    Mat grey(src.rows, src.cols, CV_8UC1, Scalar(0));
    clock_t begin_time = clock();
    for (int y = 0; y < src.rows; y++)
    {
        auto *cp = src.ptr<uchar>(y);
        auto *gp = grey.ptr<uchar>(y);
        for(int x = 0; x < src.cols; x++){
            *gp= (15*cp[0] + 75*cp[1] + 38*cp[2]) >> 7;
            cp+= 3;
            gp++;
        }
    }
    clock_t end_time = clock();
//    imshow("src",src);
//    imshow("grey",grey);
//    waitKey(0);
    fileName = "out_" + fileName;
    imwrite( fileName ,grey);
    seconds = ((double)end_time - begin_time) / CLOCKS_PER_SEC;
    allSeconds = ((double)end_time - all_begin_time) / CLOCKS_PER_SEC;
    cout<<"RGB to Grey cost time "<<seconds*1000<<" ms $$$$$  "<<seconds<<" seconds"<<endl;
    cout<<"cost all time "<<allSeconds*1000<<" ms $$$$$  "<<allSeconds<<" seconds"<<endl;
    cout<<"generate Grayscale image success,the output picture file name is "<<fileName<<endl;
    return 0;
}