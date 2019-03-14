#include <stdio.h>
int main()
{
    int a[10][10], trans[10][10], r, c, i, j;
    printf("Enter rows and column of matrix: ");
    scanf("%d %d", &r, &c);

/* Storing element of matrix entered by user in array a[][]. */
    printf("\nEnter elements of matrix:\n");
    for(i=0; i<r; ++i)
    for(j=0; j<c; ++j)
    {
        printf("Enter elements a%d%d: ",i+1,j+1);
        scanf("%d",&a[i][j]);
    }
/* Displaying the matrix a[][] */
    printf("\nEntered Matrix: \n");
    for(i=0; i<r; ++i)
    for(j=0; j<c; ++j)
    {
        printf("%d  ",a[i][j]);
        if(j==c-1){
            printf("\n\n");
        }
    }

/* Finding transpose of matrix a[][] and storing it in array trans[][]. */
    for(i=0; i<r; ++i)
    for(j=0; j<c; ++j)
    {
       trans[j][i]=a[i][j];
    }

/* Displaying the transpose,i.e, Displaying array trans[][]. */
    printf("\nTranspose of Matrix:\n");
    for(i=0; i<c; ++i)
    for(j=0; j<r; ++j)
    {
        printf("%d  ",trans[i][j]);
        if(j==r-1){
            printf("\n\n");
        }
    }
    return 0;
}
