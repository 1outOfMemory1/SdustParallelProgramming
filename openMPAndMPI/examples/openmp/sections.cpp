#include <stdio.h>
#include <omp.h>
int main()
{
    #pragma omp parallel sections
    {
        #pragma omp section
        printf("Hello from %d.\n", omp_get_thread_num());
        #pragma omp section
        printf("Hi from %d.\n", omp_get_thread_num());
        #pragma omp section
        printf("Bye from %d.\n", omp_get_thread_num());
    }
    return 0;
}
