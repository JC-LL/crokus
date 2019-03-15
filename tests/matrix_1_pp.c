#include <stdio.h>
#include <stdlib.h>

int main() {
  int mat1[10][10];
  int mat2[10][10];
  int mat3[10][10];
  int i;
  int j;
  int row1;
  int col1;
  int row2;
  int col2;
  printf("\nEnter the number of Rows of Mat1 : ");
  scanf("%d", &row1 );
  printf("\nEnter the number of Cols of Mat1 : ");
  scanf("%d", &col1 );
  printf("\nEnter the number of Rows of Mat2 : ");
  scanf("%d", &row2 );
  printf("\nEnter the number of Columns of Mat2 : ");
  scanf("%d", &col2 );
  if row1!=row2||col1!=col2 {{
    printf("\nOrder of two matrices is not same ");
    exit(0);
    }
  }
  for(i = 0;i<row1;i++){
    for(j = 0;j<col1;j++){
      printf("Enter the Element a[%d][%d] : ",i,j);
      scanf("%d", &mat1[i][j] );
      }
    }
  for(i = 0;i<row2;i++)
    for(j = 0;j<col2;j++){
      printf("Enter the Element b[%d][%d] : ",i,j);
      scanf("%d", &mat2[i][j] );
      }
  for(i = 0;i<row1;i++)
    for(j = 0;j<col1;j++){
      mat3[i][j] = mat1[i][j]+mat2[i][j];
      }
  printf("\nThe Addition of two Matrices is : \n");
  for(i = 0;i<row1;i++){
    for(j = 0;j<col1;j++){
      printf("%d\t",mat3[i][j]);
      }
    printf("\n");
    }
  return 0;
}
