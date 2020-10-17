#include <stdio.h>
int main(){
    int B;
    int i; 
#pragma omp parallel for private(B)
    for(i = 0; i<10;i++){
	B = 100; 
    } 
    printf("%d\n",B); 
    return 0;
}
