#include <stdio.h>
#include <mpi.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
// 注意这个不能作为通用的矩阵相乘 的手段使用  矩阵规模受限于核心数目
int m =10, n=20, p=30;


//生成随机矩阵
int **generate_matrix(int row,int column)
{
    int num = 0,m;
    int **matrix;
    matrix = (int **)malloc(sizeof(int *) * row);
    for(m = 0; m < row; m++)
        matrix[m] = (int *)malloc(sizeof(int) * column);
    int i,j;
    srand(time(NULL) + rand());
    for(i = 0; i < row; i++)
    {
        for(j = 0; j < column; j++)
        {
            matrix[i][j]= rand() % 20;
        }
    }
    return matrix;
}
//输出矩阵
void print_matrx(int **a,int row,int column)
{
    int i,j;
    for(i = 0; i < row; i++)
    {
        for(j = 0; j < column; j++)
        {
            printf("%d ",a[i][j]);
        }
        printf("\n");
    }
    printf("\n");
}
//矩阵相乘
int *Multiplication(int **matrix2,int *matrix1_OneRow)
{
    //矩阵相乘 matrix1_OneRow是一行  在我这个程序是一行n列    matrix2  是 n 行 p 列
    int *result;
    result = (int *)malloc(sizeof(int) * p);
    for(int j = 0;j < p;j++){ // j是针对 matrix2的某一列
        result[j] = 0;
        for(int i = 0;i < n; i++){ //i是针对matrix1_OneRow 的每个元素
            result[j] += matrix1_OneRow[i] * matrix2[i][j];  //
        }
    }
    return result;
}
int main(int argc,char **argv)
{
    int size,rank,dest;
    MPI_Comm comm = MPI_COMM_WORLD;
    MPI_Status status;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(comm,&size);
    MPI_Comm_rank(comm,&rank);
    int **matrix1;
    int **matrix2;
    int send_buff[m*n];
    matrix1 = generate_matrix(m,n);
    matrix2 = generate_matrix(n,p);
    if(rank == 0)
    {
        printf("matrix1 is :\n");
        print_matrx((int **)matrix1,m,n);
        printf("matrix2 is :\n");
        print_matrx((int **)matrix2,n,p);
        int j,k,tmp = 0;
        for(j = 0; j < m; j++)
            for(k = 0; k < n; k++)
            {
                send_buff[tmp] = matrix1[j][k];
                tmp++;
            }
    }

    int rbuf[n];
    //Multiplication((int**)matrix,)
    //分发矩阵1的行 每一行给一个进程
    MPI_Scatter(send_buff,n,MPI_INT,rbuf,n,MPI_INT,0,comm);

    // matrix1的一行(n列)和 matrix2所有列相乘 得到的result列是一行 p列的  一共分给了 m个进程执行 得到了 最终的结果是 m * p的矩阵
    int  *result = Multiplication(matrix2,rbuf);
    MPI_Barrier(comm);//等待所有进程计算结束
    int *recv_buff;
    if(rank == 0)
        recv_buff = (int*)malloc(sizeof(int)*m*p);
    MPI_Barrier(comm);

    MPI_Gather(result,p,MPI_INT,recv_buff,p,MPI_INT,0,comm);//收集各列数据
    //根进程进行输出
    if(rank == 0)
    {
        printf("\nresult is :\n");
        int i,j,tmp = 0;
        for(i = 0; i < m; i++)
        {
            for(j = 0;j < p;j++)
            {
                printf("%d ",recv_buff[tmp]);
                tmp++;
            }
            printf("\n");
        }
        printf("\n");
    }
    MPI_Finalize();
    return 0;
}
