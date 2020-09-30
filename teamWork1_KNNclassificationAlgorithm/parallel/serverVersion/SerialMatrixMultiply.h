#include "stdio.h"
/**
 * @Author: yhn
 * @Date: 2020/9/16 15:03
 * @Description: 本 .h 文件用于串行执行矩阵相乘的任务
 **/
class SerialMatrixMultiply{
private:
    long size;
    long **longArrayA; //要申请的二级指针 会调用myMalloc()函数申请一个 size * size 的数组
    long **longArrayB; //要申请的二级指针 会调用myMalloc()函数申请一个 size * size 的数组
    long **longArrayC; //要申请的二级指针 会调用myMalloc()函数申请一个 size * size 的数组

    /**
     * @brief 主要用于动态申请(malloc) size * size 的二维数组空间
     * @param longArrayX 传入引用的指针 否则就会出现断错误 因为二级指针也是一个变量 占四个字节32位空间
     */
    void  myMalloc(long  ** & longArrayX);

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
    SerialMatrixMultiply(long ssize);
    /**
     * @brief 执行矩阵相乘的命令
     */
    void multiply();
    /**
     * @brief 打印经过计算后的矩阵C 用于测试
     */
    void printCArray();
};