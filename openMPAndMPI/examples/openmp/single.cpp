#include <stdio.h>
#include <omp.h>
int main()
{
    #pragma omp parallel
    {
        printf("Run in parallel, thread id = %d.\n", omp_get_thread_num());
        #pragma omp single
        {
            printf("Run in sequence, thread id = %d.\n", omp_get_thread_num());
        }
        printf("Run in parallel, thread id = %d.\n", omp_get_thread_num());
    }
    return 0;
}
