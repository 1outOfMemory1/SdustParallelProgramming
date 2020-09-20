#include "stdio.h"
/**
 * @Author: yhn
 * @Date: 2020/9/16 15:03
 * @Description: �� .h �ļ����ڴ���ִ�о�����˵�����
 **/
class SerialMatrixMultiply{
private:
    long size;
    long **longArrayA; //Ҫ����Ķ���ָ�� �����myMalloc()��������һ�� size * size ������
    long **longArrayB; //Ҫ����Ķ���ָ�� �����myMalloc()��������һ�� size * size ������
    long **longArrayC; //Ҫ����Ķ���ָ�� �����myMalloc()��������һ�� size * size ������

    /**
     * @brief ��Ҫ���ڶ�̬����(malloc) size * size �Ķ�ά����ռ�
     * @param longArrayX �������õ�ָ�� ����ͻ���ֶϴ��� ��Ϊ����ָ��Ҳ��һ������ ռ�ĸ��ֽ�32λ�ռ�
     */
    void  myMalloc(long  ** & longArrayX);

    /**
     * @brief ��Ҫ���ڸ������ֵ��̬����ռ� ����ʼ��ֵ ÿ�е����� ��1 - size
     * @param longArrayX  �������õ�ָ�� ����ͻ���ֶϴ��� ��Ϊ����ָ��Ҳ��һ������ ռ�ĸ��ֽ�32λ�ռ�
     */
    void setArray(long ** & longArrayX);

    /**
     * @brief  setZero������Ҫ���ڸ�һ����ά���鸳��ֵΪ0
     * @param longArrayX ��Ҫȫ��������������ָ��
     */
    void setZero(long ** & longArrayX);

    /**
     * @brief  ��ӡ����Ķ�ά�����ֵ ���ڵ���
     * @param longArrayX  ��Ҫ��ӡ������ָ��
     */
    void print(long ** longArrayX);

public:
    /**
     * @brief  ������� setarray�������ٿռ�
     * @param ssize  MatrixMultiply��Ĺ��캯��
     */
    SerialMatrixMultiply(long ssize);
    /**
     * @brief ִ�о�����˵�����
     */
    void multiply();
    /**
     * @brief ��ӡ���������ľ���C ���ڲ���
     */
    void printCArray();
};