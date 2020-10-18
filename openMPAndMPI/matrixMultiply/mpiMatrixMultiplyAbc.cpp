#include<iostream>
using namespace std;
#include<mpi.h>

int main(){
    int my_rank;
    int num_procs;
    int size = 1000;
    double start, finish;

    MPI_Init(NULL,NULL);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

    int distributionTime = size / num_procs;
    int * local_a = new int [ distributionTime * size ];
    int * b = new int [ size * size ];
    int * ans = new int [ distributionTime * size ];
    int * a = new int [ size * size ];
    int * c = new int [ size * size ];

    if( my_rank == 0 ){
        cout<<" distributionTime = "<<distributionTime<<endl;
        start = MPI_Wtime();
        for(int i=0;i<size;i++){
            for(int j=0;j<size;j++){
                a[ i*size + j ] = 1;
                b[ i*size + j ] = 2;
            }
        }
        MPI_Scatter(a, distributionTime * size, MPI_INT, local_a, distributionTime * size, MPI_INT, 0, MPI_COMM_WORLD );
        MPI_Bcast(b, size*size, MPI_INT, 0, MPI_COMM_WORLD);

        for(int i= 0; i< distributionTime;i++){
            for(int j=0;j<size;j++){
                int temp = 0;
                for(int k=0;k<size;k++)
                    temp += a[i*size+k] * b[k*size + j];
                ans[i*size + j ] = temp;
            }
        }
        MPI_Gather( ans, distributionTime * size, MPI_INT, c, distributionTime * size, MPI_INT, 0, MPI_COMM_WORLD );

        for(int i= num_procs *distributionTime; i< size;i++){
            for(int j=0;j<size;j++){
                int temp = 0;
                for(int k=0;k<size;k++)
                    temp += a[i*size+k] * b[k*size + j];
                c[i*size + j ] = temp;
            }
        }

//        FILE *fp = fopen("c2.txt","w");
//        for(int i=0;i<size;i++){
//            for(int j=0;j<size;j++)
//                fprintf(fp,"%d\t",c[i*size+j]);
//            fputc('\n',fp);
//        }
//        fclose(fp);

        finish = MPI_Wtime();
        printf(" time: %lf s \n", finish - start );
    }
    else{
        int * buffer = new int [ size * distributionTime ];
        MPI_Scatter(a, distributionTime * size, MPI_INT, buffer, distributionTime * size, MPI_INT, 0, MPI_COMM_WORLD );
        MPI_Bcast( b, size * size, MPI_INT, 0, MPI_COMM_WORLD );

//        cout<<" b:"<<endl;
//        for(int i=0;i<size;i++){
//            for(int j=0;j<size;j++){
//                cout<<b[i*size + j]<<",";
//            }
//            cout<<endl;
//        }
        for(int i=0;i<distributionTime;i++){
            for(int j=0;j<size;j++){
                int temp = 0;
                for(int k=0;k<size;k++)
                    temp += buffer[i*size+k] * b[k*size + j];
                //cout<<"i = "<<i<<"\t j= "<<j<<"\t temp = "<<temp<<endl;
                ans[i*size + j] = temp;
            }
        }
        MPI_Gather(ans, distributionTime*size, MPI_INT, c, distributionTime*size, MPI_INT, 0, MPI_COMM_WORLD );
        delete [] buffer;
    }

    if(my_rank == 0){

        cout<<" ans:"<<endl;
        for(int i=0;i<distributionTime;i++){
            for(int j=0;j<size;j++){
                cout<<ans[i*size + j]<<",";
            }
            cout<<endl;
        }

    }

    delete [] a, local_a, b, ans, c;

    MPI_Finalize();
    return 0;
}