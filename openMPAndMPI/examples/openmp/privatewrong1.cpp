#include <stdio.h>
int main(){
    int A=100;
    int i;
    #pragma omp parallel for private(A)
    for(i = 0; i<10;i++){
    	printf("%d\n",A);
    }
    return 0;
}
