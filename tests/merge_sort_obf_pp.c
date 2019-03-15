#include "sort.h"

void merge(int32_t a[SIZE],int start,int m,int stop) {
  int32_t temp[SIZE];
  int i;
  int j;
  int k;
  for(i = start;i<=m;i++){
    temp[i] = a[i];
    }
  for(j = m+1;j<=stop;j++){
    temp[m+1+stop-j] = a[j];
    }
  i = start;
  j = stop;
  for(k = start;k<=stop;k++){
    int32_t tmp_j = temp[j];
    int32_t tmp_i = temp[i];
    if (tmp_j<tmp_i) {{
      a[k] = tmp_j;
      j--;
      }
    }
    else {{
      a[k] = tmp_i;
      i++;
      }
    }
    }
}

void ms_mergesort_obf(int32_t a[SIZE]) {
  int control = 1;
  int start;
  int stop;
  int i;
  int m;
  int from;
  int mid;
  int to;
  while ((control!=0))
    switch(control){
    }
}
