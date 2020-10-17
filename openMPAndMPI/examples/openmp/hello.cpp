#include <iostream>  
#include <omp.h> // OpenMP编程需要包含的头文件  
using namespace std;

int main() {  
    int sum = 0;    
    cout << "Before: " << sum << endl;    
#pragma omp parallel for shared(sum)   
    for (int i = 0; i < 10; ++i) {  
        sum += i;  
        cout << "thread id :"<< omp_get_thread_num() << "sum :" << sum << endl;  
    }  
    cout << "After: " << sum << endl;  
    return 0;  
} 
