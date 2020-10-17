#include <iostream>  
#include <omp.h>   
using namespace std;  
int main() {  
    int sum = 0;    
    cout << "Before: " << sum << endl;    
#pragma omp parallel for shared(sum)   
    for (int i = 0; i < 10; ++i) {  
        sum += i;  
        //cout << "sum :" << sum << endl;  
    }  
    cout << "After: " << sum << endl;  
    return 0;  
} 
