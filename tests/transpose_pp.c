#include <stdio.h>

int main() {
  int a[10][10];
  int trans[10][10];
  int r;
  int c;
  int i;
  int j;
  printf("Enter rows and column of matrix: ");
  scanf("%d %d", &r , &c );
  printf("\nEnter elements of matrix:\n");
  for(i = 0;i<r;++i)
    for(j = 0;j<c;++j){
      printf("Enter elements a%d%d: ",i+1,j+1);
      scanf("%d", &a[i][j] );
      }
  printf("\nEntered Matrix: \n");
  for(i = 0;i<r;++i)
    for(j = 0;j<c;++j){
      printf("%d  ",a[i][j]);
      if j==c-1 {{
        printf("\n\n");
        }
      }
      }
  for(i = 0;i<r;++i)
    for(j = 0;j<c;++j){
      trans[j][i] = a[i][j];
      }
  printf("\nTranspose of Matrix:\n");
  for(i = 0;i<c;++i)
    for(j = 0;j<r;++j){
      printf("%d  ",trans[i][j]);
      if j==r-1 {{
        printf("\n\n");
        }
      }
      }
  return 0;
}
