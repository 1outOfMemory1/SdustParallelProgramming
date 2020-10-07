#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "opencv2/core.hpp"
#include "opencv2/highgui.hpp"
#include <iostream>
#include <string>
using namespace cv;
using namespace std;


// global variables
int pictureHeight,pictureWidth; // define how many pixels of picture in the row and column
string pictureUrl = "D:/in.jpg";
int threadSize = 32;
__global__ void numberMultiplyMatrix(unsigned char * uCharArrayB,  // Initial array
                                     unsigned char * uCharArrayG,  // Initial array
                                     unsigned char * uCharArrayR,  // Initial array
                                     unsigned char * uCharArrayGrey,  // Result array that after multiply a coefficient
                                     int picWidth){
    // B 0.114   G 0.587  R 0.299
    int row = blockDim.x * blockIdx.x + threadIdx.x;
    int col = blockDim.y * blockIdx.y + threadIdx.y;

    uCharArrayGrey[row * picWidth + col] = (15*uCharArrayB[row * picWidth + col] +
                                            75*uCharArrayG[row * picWidth + col] +
                                            38*uCharArrayR[row * picWidth + col] )>> 7;
}
int main(int argc,char * argv[])
{
    double seconds;
    string fileName = "";
    clock_t begin_time = clock();
    if(argc > 1){
        pictureUrl = argv[1];
        cout<<"already input value,file name is "<<pictureUrl<<endl;
    }else{
        cout<<"no input value found,default picture file path is "<<pictureUrl<<endl;
    }
    int i=pictureUrl.size()-1;
    for(;i>=0;i--){
        if(pictureUrl[i] == '/' || pictureUrl[i] == '\\' ){
            fileName = pictureUrl.substr(i+1,pictureUrl.size());
            break;
        }
    }
    if(i <= 0)
        fileName = pictureUrl;


    Mat rawPic = imread(pictureUrl);
    Mat greyPic(rawPic.rows, rawPic.cols, CV_8UC1, Scalar(0));
    if(rawPic.empty()){
        cout<<"input picture not found, please check your path"<<endl;
        exit(-1);
    }
    pictureHeight = rawPic.rows;
    pictureWidth = rawPic.cols;
    unsigned char *uCharArrayB = new unsigned char[pictureHeight *pictureWidth]; // host memory
    unsigned char *uCharArrayG = new unsigned char[pictureHeight *pictureWidth]; // host memory
    unsigned char *uCharArrayR = new unsigned char[pictureHeight *pictureWidth]; // host memory
    unsigned char *uCharArrayGrey = new unsigned char[pictureHeight *pictureWidth]; // host memory
    unsigned char *cudaUCharArrayB; // cuda memory
    unsigned char *cudaUCharArrayG; // cuda memory
    unsigned char *cudaUCharArrayR; // cuda memory
    unsigned char *cudaUCharArrayGrey; // cuda memory
    //assign 3 channels values to three unsigned char array
    for (int i = 0; i < pictureHeight; i++)
    {
        unsigned char *cp = rawPic.ptr<uchar>(i);
        for(int j = 0; j < pictureWidth; j++){
            uCharArrayB[i * pictureWidth + j] = cp[0];
            uCharArrayG[i * pictureWidth + j] = cp[1];
            uCharArrayR[i * pictureWidth + j] = cp[2];
            cp+=3;
        }
    }
    // apply for display memory
    cudaMalloc((void**)&cudaUCharArrayB,sizeof(unsigned char) * pictureWidth * pictureHeight); //
    cudaMalloc((void**)&cudaUCharArrayG,sizeof(unsigned char) * pictureWidth * pictureHeight);  //
    cudaMalloc((void**)&cudaUCharArrayR,sizeof(unsigned char) * pictureWidth * pictureHeight); //
    cudaMalloc((void**)&cudaUCharArrayGrey,sizeof(unsigned char) * pictureWidth * pictureHeight); //
    // copy data from host memory to display memory
    cudaMemcpy(cudaUCharArrayB,uCharArrayB,pictureHeight * pictureWidth * sizeof(unsigned char),cudaMemcpyHostToDevice);
    cudaMemcpy(cudaUCharArrayG,uCharArrayG,pictureHeight * pictureWidth * sizeof(unsigned char),cudaMemcpyHostToDevice);
    cudaMemcpy(cudaUCharArrayR,uCharArrayR,pictureHeight * pictureWidth * sizeof(unsigned char),cudaMemcpyHostToDevice);
    cudaEvent_t start,stop;
    float elapsedTime = 0;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start,0);
    // execute cuda  kernel function
    numberMultiplyMatrix<<<dim3(pictureHeight/threadSize,
                                pictureWidth/threadSize),
                                dim3(threadSize,threadSize)>>>
                                (cudaUCharArrayB,cudaUCharArrayG,cudaUCharArrayR,cudaUCharArrayGrey,pictureWidth);
    cudaEventRecord(stop,0);
    cudaMemcpy(uCharArrayGrey,cudaUCharArrayGrey,pictureHeight * pictureWidth * sizeof(unsigned char),cudaMemcpyDeviceToHost);
    cudaThreadSynchronize();

    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedTime,start,stop);
    printf("cost time : %f ms $$$$ %f s \n",elapsedTime,elapsedTime/1000);
    // copy the result to opencv Mat type ,in order to show the picture
    for (int i = 0; i < pictureHeight; i++)
    {
        unsigned char *cp = greyPic.ptr<uchar>(i);
        for(int j = 0; j < pictureWidth; j++){
            cp[0] =  uCharArrayGrey[i*pictureWidth + j];
            cp++;
        }
    }
    // show pictures
//    imshow("init",rawPic);
//    imshow("grey",greyPic);
//    waitKey(0);
    // convert Mat type to picture (type jpg)
    fileName = "out_" + fileName;
    imwrite(fileName,greyPic);
    cout<<"generate Grayscale image success,the output picture file name is "<<fileName<<endl;
    clock_t end_time = clock();
    seconds = ((double)end_time - begin_time) / CLOCKS_PER_SEC;
    cudaFree(cudaUCharArrayB);
    cudaFree(cudaUCharArrayG);
    cudaFree(cudaUCharArrayR);
    cudaFree(cudaUCharArrayGrey);
    delete[] uCharArrayB;
    delete[] uCharArrayG;
    delete[] uCharArrayR;
    delete[] uCharArrayGrey;
    cout<<"cost total time "<<seconds<<" seconds"<<endl;
    return 0;
}