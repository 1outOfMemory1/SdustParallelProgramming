#include <stdio.h>
#include <omp.h>
int main()
{
    int k, i;
    k = 100;
    #pragma omp parallel for firstprivate(k),lastprivate(k)
    for (i = 0; i < 8; i++)
    {
        k += i;
        printf("k = %d in thread %d.\n", k, omp_get_thread_num());
    }
    printf("Finally, k = %d.\n", k);
    return 0;
}
