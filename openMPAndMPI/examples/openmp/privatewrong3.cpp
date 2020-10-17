#include <stdio.h>
int main(){
    int C = 100,i; 
#pragma omp parallel for private(C)
    for(i = 0; i<10;i++){
	C = 200; 
	printf("%d\n",C);
    }
    printf("%d\n",C); 
    return 0;
}
