#include <stdio.h>
#include <mpi.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <iostream>
#include <omp.h>
// 注意这个不能作为通用的矩阵相乘 的手段使用  矩阵规模受限于核心数目
using namespace std;
int m =1000, n=2000, p=3000;
int  arrayARowNum = m;

//生成随机矩阵
double *generate_matrix(int row,int column)
{
    double *doubleMatrix = new double[row * column];
    int matrixSize = row * column;
    srand(time(0) );
    for(int i=0;i<matrixSize;i++){
        doubleMatrix[i] =  1 ;
    }
    return doubleMatrix;
}


int main(int argc,char **argv)
{
    int num_procs,rank,threadNum=2;
    MPI_Comm comm = MPI_COMM_WORLD;
    MPI_Status status;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(comm,&num_procs);
    MPI_Comm_rank(comm,&rank);
    int singleProcessRowNum = arrayARowNum / num_procs;
    double * multipleRow = new double[ n * singleProcessRowNum ];
    double *matrix1;
    double *matrix2 = new double[n*p];
    double *allResult = new double [m*p];
    double startTime = 0;
    double endTime = 0;
    if(rank == 0)
    {
        printf("threadNum = %d\n",threadNum);
        startTime = MPI_Wtime();
        // 一共是分发几次 比如有A数组是 300 * 200 的数组 将mpi分给10个进程 那么就有
        // 每个进程分的数目就是 int(arrayARowNum / num_procs) = 300/10  = 30 这么多个行数据
        // 剩下的 一些边角 需要再考虑
        matrix1 = generate_matrix(m,n);
        matrix2 = generate_matrix(n,p);
//        matrix1 = new double[m*n];
//        matrix1[0] = 1;
//        matrix1[1] = 2;
//        matrix1[2] = 3;
//        matrix1[3] = 4;
//        matrix1[4] = 5;
//        matrix1[5] = 6;
//        matrix1[6] = 7;
//        matrix1[7] = 8;
//        matrix2[0] = 1;
//        matrix2[1] = 2;
//        matrix2[2] = 3;
//        matrix2[3] = 4;
//        printf("matrix1 is :\n");
//        for(int i = 0; i < m; i++){
//            for(int j = 0; j < n; j++){
//                printf("%.2lf ",matrix1[i*n + j]);
//            }
//            printf("\n");
//        }
//        printf("\n");
//
//        printf("matrix2 is :\n");
//        for(int i = 0; i < n; i++){
//            for(int j = 0; j < p; j++){
//                printf("%.2lf ",matrix2[i*n + j]);
//            }
//            printf("\n");
//        }
//        printf("\n");
    }
    // 把整个matrix2数组广播出去
    MPI_Bcast(matrix2, n * p, MPI_DOUBLE, 0, MPI_COMM_WORLD );
    //把matrix1 的行分发出去 每个进程分发 singleProcessRowNum * n 个数据 一共 singleProcessRowNum 行
    MPI_Scatter(matrix1,singleProcessRowNum * n ,MPI_DOUBLE, multipleRow,singleProcessRowNum * n ,MPI_DOUBLE,0,MPI_COMM_WORLD );



    double *resultMultipleRow = new double[singleProcessRowNum * p];
    for(int i=0;i<singleProcessRowNum * p;i++){
        resultMultipleRow[i] = 0;
    }
    //矩阵的计算
    int j;
    int k;
    omp_set_num_threads(threadNum);
    #pragma omp  parallel  for private(j, k)
    for (int i = 0; i < singleProcessRowNum; ++i) {
        for (j = 0; j < n; ++j) {
            for (k = 0; k < p; ++k) {
                resultMultipleRow[i*p + k] += multipleRow[i*n + j] * matrix2[j*p + k];
            }
        }
    }
    MPI_Barrier(comm);
    MPI_Gather(resultMultipleRow, singleProcessRowNum * p, MPI_DOUBLE,allResult, singleProcessRowNum * p, MPI_DOUBLE, 0, MPI_COMM_WORLD );
    if(rank ==0){
//        printf("result \n");
//        for(int i=0;i<m;i++){
//            for(int j =0;j<p;j++){
//                printf("%.2lf ",allResult [i * p + j]);
//            }
//            printf("\n");
//        }

        endTime = MPI_Wtime();

        printf(" time: %lf s \n", endTime - startTime );


    }
    MPI_Finalize();
    delete []multipleRow;
    delete []matrix2;
    delete []allResult;
    return 0;
}
