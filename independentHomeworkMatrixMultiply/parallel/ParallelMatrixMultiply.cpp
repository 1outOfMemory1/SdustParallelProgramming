//
// Created by yhn on 2020/9/18.
//

#include "ParallelMatrixMultiply.h"

void ParallelMatrixMultiply::myMemoryMolloc(long **&longArrayX) {
    //申请空间   size * size 个空间
    longArrayX = new long*[size];
    for(long i= 0;i<size;i++){
        longArrayX[i] = new long[size];
    }
}

void ParallelMatrixMultiply::myGraphicsMemoryMolloc() {

}

cudaError_t ParallelMatrixMultiply::multiply() {
        int *dev_a = 0;
        int *dev_b = 0;
        int *dev_c = 0;
        cudaError_t cudaStatus;

        // Choose which GPU to run on, change this on a multi-GPU system.
        //选择一个GPU去跑程序 如果你有多个GPU的话 可以进行切换
        cudaStatus = cudaSetDevice(0);
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "GPU选择失败 请查看选择的GPU是否正确 cudaSetDevice failed!  Do you have a CUDA-capable GPU installed? \n ");
            goto Error;
        }

        // Allocate GPU buffers for three vectors (two input, one output)
        //以下三块 是在GPU中申请显存空间 申请的空间是一个数组的大小
        cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(int));
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "1 显存申请失败 cudaMalloc failed!");
            goto Error;
        }

        cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(int));
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "2 显存申请失败 cudaMalloc failed!");
            goto Error;
        }

        cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(int));
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "3 显存申请失败 cudaMalloc failed!");
            goto Error;
        }

        // Copy input vectors from host memory to GPU buffers.
        //以下两块是 将内存中存储的 a数组和b数组的内容拷贝到GPU显存中去
        cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "1 将数据从内存复制到显存失败 cudaMemcpy failed!");
            goto Error;
        }

        cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "2 将数据从内存复制到显存失败 cudaMemcpy failed!");
            goto Error;
        }



        // Launch a kernel on the GPU with one thread for each element.
        //以下是真正的并行程序的执行代码 申请了一个块 里边有传入参数size个int的空间  程序的主要内容是 a b数组相加得到数组c
        addKernel<<<1, size>>>(dev_c, dev_a, dev_b);

        // Check for any errors launching the kernel
        //检查在启动核心的时候是否存在错误 如果存在就报错
        cudaStatus = cudaGetLastError();
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "启动核心失败 addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
            goto Error;
        }

        // cudaDeviceSynchronize waits for the kernel to finish, and returns
        // any errors encountered during the launch.
        // 下方函数等待并行程序执行完毕 如果执行出错误 那么就结束程序 输出错误信息
        cudaStatus = cudaDeviceSynchronize();
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "GPU核心运算出错  cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
            goto Error;
        }

        // Copy output vector from GPU buffer to host memory.
        // 这一步将已经在GPU算好的内容存入内存中的 c中以便于程序读取
        cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "将GPU显存中的数据存入到内存中失败 cudaMemcpy failed!");
            goto Error;
        }


        //程序的最后进行内存的释放   如果上述过程出现错误也会直接跳转到这个地方进行显存的释放
        Error:
        cudaFree(dev_c);
        cudaFree(dev_a);
        cudaFree(dev_b);

        return cudaStatus;  //返回最终的cuda执行情况 如果有报错 那么可以查找到报错代号


}



