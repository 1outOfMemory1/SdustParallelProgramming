//
// Created by 尹浩男 on 2020/9/24.
//
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <set>
#include <algorithm>
#ifndef HELLO_CSV_H
#define HELLO_CSV_H

using namespace std;

class Csv {
private:
    ifstream *file;
    string stringOfResult;  //这个是需要预测的列的名字
    set<string> *realitySet; //# 这个是用来存储结果可能的所有种类 比如预测是否得病只有 两种可能 得病和不得病
    const char symbol = ',';  //定义用什么符号分割 默认读取csv文件 用逗号分割
    vector<string> *rowVector;    //里边存放了所有的字符串数据 需要进行转换
    vector<string> * header;  //存放头的信息 不包括预测的名字
    vector<vector<double>> *doubleDataArray; //二维数组 用来存放数据
    vector<string> *stringResultVector;  //用于存储结果列中的所有数据
    void init();  // 初始化 用来动态开辟空间的函数
    /**
     * @brief 传入字符串和分隔符 返回一个string的vector  相当于python或者java的split函数
     * @param (string) str   要分割的字符串
     * @param (char) symbol  分隔符
     * @return (vector<string>*) 返回一个string的vector
     */
    vector<string>* getStringVector(string str,char symbol);


    /**
     * @brief 将string
     * @param strVector
     * @return
     */
    vector<double>* stringVectorToDoubleVector(vector<string> *strVector);
public:
    Csv(ifstream *file);  //构造函数
    virtual ~Csv();  // 析构函数  用来free一些new的内容
    vector<vector<double>> *  getDoubleData();  //获取数据的而二维数组vector
    vector<string> * getHeaderNameVector();
    vector<string> * getResultVector();
    set<string> * getResultSet();
    void printHeaderVector();  //打印 Header列的名字 不包括结果列的名字
    void printDoubleDataVector();  //打印所有数据
    void printResultInformation(); //打印有关结果列的信息 包括结果列的名称 和 结果列中所有可能的值(无重复)
    void printResultVector();   //打印结果列的所有数据
};


#endif //HELLO_CSV_H
