//
// Created by yhn on 2020/9/18.
//

#ifndef HELLO_PARALLELMATRIXMULTIPLY_H
#define HELLO_PARALLELMATRIXMULTIPLY_H
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <cstdio>

/**
 * @Author: yhn
 * @Date: 2020/9/18 21:03
 * @Description: 本 .h 文件用于并行执行矩阵相乘的任务
 **/



class ParallelMatrixMultiply {
private:
    long size;
    long **longArrayA;
    long **longArrayB;
    long **longArrayC;
    /**
     * @brief 主要用于动态申请内存 (malloc) size * size 的二维数组空间
     * @param longArrayX 传入引用的指针 否则就会出现断错误 因为二级指针也是一个变量 占四个字节32位空间
     */
    void myMemoryMolloc(long ** & longArrayX);

    /**
     * @brief 主要用于动态申请      ****   显示内存  *****          (malloc) size * size 的二维数组空间
     */
    void myGraphicsMemoryMolloc();

    /**
     * @brief 主要用于给传入的值动态申请空间 并初始化值 每行的数据 从1 - size
     * @param longArrayX  传入引用的指针 否则就会出现断错误 因为二级指针也是一个变量 占四个字节32位空间
     */
    void setArray(long ** & longArrayX);

    /**
     * @brief  setZero函数主要用于给一个二维数组赋初值为0
     * @param longArrayX 需要全部置零的数组二级指针
     */
    void setZero(long ** & longArrayX);

        /**
     * @brief  打印传入的二维数组的值 用于调试
     * @param longArrayX  需要打印的数组指针
     */
    void print(long ** longArrayX);
public:
    /**
     * @brief  构造调用 setarray函数开辟空间
     * @param ssize  MatrixMultiply类的构造函数
     */
    ParallelMatrixMultiply(long ssize);

    /**
     * @brief 执行矩阵相乘的命令
     */
    cudaError_t multiply();
    /**
     * @brief 打印经过计算后的矩阵C 用于测试
     */
    void printCArray();

};


#endif //HELLO_PARALLELMATRIXMULTIPLY_H
