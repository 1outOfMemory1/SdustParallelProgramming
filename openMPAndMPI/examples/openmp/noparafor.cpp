#include <stdio.h>
#include <omp.h>
int main()
{
    int i;
    #pragma omp for
    for (i = 0; i < 4; i++)
        printf("i = %d, threadId = %d.\n", i, omp_get_thread_num());
    return 0;
}
