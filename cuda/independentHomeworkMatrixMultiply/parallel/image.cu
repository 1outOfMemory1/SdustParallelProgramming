#include <cuda_runtime.h>
#include <vector>
#include <iostream>
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

// 图像的宽高
const int row = 700;
const int col = 1400;
// 25X25
const int x = 25;
const int y = 25;
// 二维数组
int ** myMalloc(int row, int col) {
    int** arr = new int*[row];
    for (int i = 0; i < row; i++) {
        arr[i] = new int[col];
    }
    return arr;
}
// Mat转换成二维数组
int ** mat2Array(Mat mat) {
    int** arr = myMalloc(mat.rows, mat.cols);
    for (int i = 0; i < mat.rows; i++) {
        for (int j = 0; j < mat.cols; j++) {
            arr[i][j] = mat.at<uchar>(i, j);
        }
    }
    return arr;
}
// 二维数组转换成Mat
Mat array2Mat(int arr[row][col], int row, int col) {
    Mat mat(row, col, CV_8UC1);
    unsigned char *pTmp = NULL;
    for (int i = 0; i < row; i++) {
        pTmp = mat.ptr(i);
        for (int j = 0; j < col; j++) {
            pTmp[j] = arr[i][j];
        }
    }
    return mat;
}
// 数乘
__global__ void numMul(int a[row][col], int num, int result[row][col]) {
    int colG = blockDim.x * blockIdx.x + threadIdx.x;
    int rowG = blockDim.y * blockIdx.y + threadIdx.y;
    result[colG][rowG] = a[colG][rowG] * num;
}

// 矩阵相加
__global__ void matAdd1(int a[row][col], int b[row][col], int result[row][col]) {
    int colG = blockDim.x * blockIdx.x + threadIdx.x;
    int rowG = blockDim.y * blockIdx.y + threadIdx.y;
    result[rowG][colG] = a[rowG][colG] + b[rowG][colG];
}
__global__ void matAdd2(int a[row][col], int num, int result[row][col]) {
    int colG = blockDim.x * blockIdx.x + threadIdx.x;
    int rowG = blockDim.y * blockIdx.y + threadIdx.y;
    result[rowG][colG] = a[rowG][colG] + num;
}
// 除
__global__ void matDiv(int a[row][col], int num, int result[row][col]) {
    int colG = blockDim.x * blockIdx.x + threadIdx.x;
    int rowG = blockDim.y * blockIdx.y + threadIdx.y;
    result[rowG][colG] = a[rowG][colG] / num;
}

int main() {
    Mat src = imread("in.jpg");
    // 通道分割
    vector<Mat> channels;
    split(src, channels);
    Mat B = channels[0];
    Mat G = channels[1];
    Mat R = channels[2];
    // mat2array
    int **bArray = mat2Array(B);
    int **gArray = mat2Array(G);
    int **rArray = mat2Array(R);
    // 分配存储空间
    int (*tmp1)[col];
    int (*tmp2)[col];
    int (*tmp3)[col];
    int (*result1)[col];
    int (*result2)[col];
    int (*result3)[col];
    int (*result4)[col];
    int (*result5)[col];
    int (*result6)[col];
    int (*result7)[col];
    cudaMalloc((void**)&tmp1, sizeof(int)*row*col);
    cudaMalloc((void**)&tmp2, sizeof(int)*row*col);
    cudaMalloc((void**)&tmp3, sizeof(int)*row*col);
    cudaMalloc((void**)&result1, sizeof(int)*row*col);
    cudaMalloc((void**)&result2, sizeof(int)*row*col);
    cudaMalloc((void**)&result3, sizeof(int)*row*col);
    cudaMalloc((void**)&result4, sizeof(int)*row*col);
    cudaMalloc((void**)&result5, sizeof(int)*row*col);
    cudaMalloc((void**)&result6, sizeof(int)*row*col);
    cudaMalloc((void**)&result7, sizeof(int)*row*col);
    int (*bArray_c)[col] = new int[row][col];
    int (*gArray_c)[col] = new int[row][col];
    int (*rArray_c)[col] = new int[row][col];
    for (int i = 0; i < row; i++) {
        for (int j = 0; j < col; j++) {
            bArray_c[i][j] = bArray[i][j];
            gArray_c[i][j] = gArray[i][j];
            rArray_c[i][j] = rArray[i][j];
        }
    }
    cudaMemcpy(tmp1, bArray_c, sizeof(int)*row*col, cudaMemcpyHostToDevice);
    cudaMemcpy(tmp2, gArray_c, sizeof(int)*row*col, cudaMemcpyHostToDevice);
    cudaMemcpy(tmp3, rArray_c, sizeof(int)*row*col, cudaMemcpyHostToDevice);
    // =========
    dim3 threadsPerBlock(x, y);
    // =========
    dim3 blocksPerGrid(row / threadsPerBlock.x, col / threadsPerBlock.y);
    // ====
    cudaEvent_t start, finish;
    float elapsedTime;
    cudaEventCreate(&start);
    cudaEventCreate(&finish);
    cudaEventRecord(start, 0);

    numMul <<< blocksPerGrid, threadsPerBlock >>> (tmp1, 299, result1);
    numMul <<< blocksPerGrid, threadsPerBlock >>> (tmp2, 587, result2);
    numMul <<< blocksPerGrid, threadsPerBlock >>> (tmp3, 114, result3);
    matAdd1 <<< blocksPerGrid, threadsPerBlock >>> (result1, result2, result4);
    matAdd1 <<< blocksPerGrid, threadsPerBlock >>> (result3, result4, result5);
    matAdd2 <<< blocksPerGrid, threadsPerBlock >>> (result5, 500, result6);
    matDiv <<< blocksPerGrid, threadsPerBlock >>> (result6, 1000, result7);

    cudaEventRecord(finish, 0);
    cudaEventSynchronize(start);
    cudaEventSynchronize(finish);
    cudaEventElapsedTime(&elapsedTime, start, finish);
    cout << elapsedTime << " ms" << endl;

    // ====
    int (*resultArray)[col] = new int[row][col];
    cudaMemcpy(resultArray, result7, sizeof(int)*row*col, cudaMemcpyDeviceToHost);
    Mat result = array2Mat(resultArray, row, col);
    // 保存图片
    imwrite("out.jpg", result);
    // 释放存储空间
    cudaFree(tmp1);
    cudaFree(tmp2);
    cudaFree(tmp3);
    cudaFree(result1);
    cudaFree(result2);
    cudaFree(result3);
    cudaFree(result4);
    cudaFree(result5);
    cudaFree(result6);
    cudaFree(result7);
    delete [] resultArray;
    return 0;
}