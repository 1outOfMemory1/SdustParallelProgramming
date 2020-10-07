#include <iostream>
#include <cmath>
#include <fstream>
#include <cuda_runtime.h>
using namespace std;

// 训练集的大小
const int train_col = 8;
const int train_row = 614;
// 测试集的大小
const int test_col = 8;
const int test_row = 154;
// block中线程排列
const int matSub_x = 2;
const int matSub_y = 2;
const int distance_x = train_row;
const int distance_y = 1;
// 预测结果
double prediction[test_row];
__global__ void matSub(double **A, double **B, double **C) {
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    int row = blockDim.y * blockIdx.y + threadIdx.y;
    double tmp = A[row][col] - B[row][col];
    C[row][col] = tmp * tmp;
}
__global__ void distance(double **C, double *D) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    double tmp = 0;
    for (int k = 0; k < train_col; k++) {
        tmp += C[i][k];
    }
    D[i] = sqrt(tmp);
}

int main() {
    // 加载数据
    ifstream x_train_in("X_train.csv");
    ifstream y_train_in("Y_train.csv");
    ifstream x_test_in("X_test.csv");
    ifstream y_test_in("Y_test.csv");
    // 训练集
    double **x_train = new double*[train_row];
    for (int i = 0; i < train_row; i++) {
        x_train[i] = new double[train_col];
    }
    double *y_train = new double[train_row];
    // 测试集
    double **x_test = new double*[test_row];
    for (int i = 0; i < test_row; i++) {
        x_test[i] = new double[test_col];
    }
    double *y_test = new double[test_row];
    for (int i = 0; i < train_row; i++) {
        for (int j = 0; j < train_col; j++) {
            x_train_in >> x_train[i][j];
        }
    }
    for (int i = 0; i < train_row; i++) {
        y_train_in >> y_train[i];
    }
    for (int i = 0; i < test_row; i++) {
        for (int j = 0; j < test_col; j++) {
            x_test_in >> x_test[i][j];
        }
    }
    for (int i = 0; i < test_row; i++) {
        y_test_in >> y_test[i];
    }
    // ====
    double **A = new double*[train_row];
    double **B = new double*[train_row];
    double **C = new double*[train_row];
    double *D;
    double *result = new double[train_row];
    cudaMalloc((void**)&D, sizeof(double)*train_row);
    for (int i = 0; i < test_row; i++) {
        for (int j = 0; j < train_row; j++) {
            cudaMalloc((void**)&A[j], sizeof(double)*train_col);
            cudaMalloc((void**)&B[j], sizeof(double)*train_col);
            cudaMalloc((void**)&C[j], sizeof(double)*train_col);
            cudaMemcpy(A[j], x_train[j], sizeof(double)*train_col, cudaMemcpyHostToDevice);
            cudaMemcpy(B[j], x_test[i], sizeof(double)*train_col, cudaMemcpyHostToDevice);
            dim3 threadsPerBlock(matSub_x, matSub_y);
            dim3 blocksPerGrid(train_col / threadsPerBlock.x, train_row / threadsPerBlock.y);
            matSub <<< blocksPerGrid, threadsPerBlock >>> (A, B, C);
            dim3 threadsPerBlock1(distance_x, distance_y);
            dim3 blocksPerGrid1(train_row / threadsPerBlock1.x, 1);
            distance <<< blocksPerGrid1, threadsPerBlock1 >>> (C, D);
            cudaMemcpy(result, D, sizeof(double)*train_row, cudaMemcpyDeviceToHost);
            int index = 0;
            double minn = result[index];
            for (int k = 1; k < train_row; k++) {
                if (minn > result[k]) {
                    index = k;
                }
            }
            prediction[i] = y_train[index];
        }
    }
    int cnt = 0;
    for (int i = 0; i < train_row; i++) {
        if (prediction[i] == y_test[i]) {
            ++cnt;
        }
    }
    cout << (double)cnt / test_row << endl;
    // ====
    // 释放空间
    cudaFree(D);
    delete [] result;
    for (int i = 0; i < train_row; i++) {
        delete [] x_train[i];
    }
    delete [] y_train;
    for (int i = 0; i < test_row; i++) {
        delete [] x_test[i];
    }
    delete [] y_test;
    return 0;
}