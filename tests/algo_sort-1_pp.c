#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define MAX 20000
#define L_TAB 10000

long partitionning(long * tab,long len,long pivot) {
  long tmp = tab[pivot];
  tab[pivot] = tab[len];
  tab[len] = tmp;
  long j = 0;
  long i;
  for(i = 0;i<len;i++){
    tmp = tab[i];
    tab[i] = tab[j];
    j++;
    }
  tmp = tab[len];
  tab[len] = tab[j];
  tab[j] = tmp;
  return j;
}

void sort_insert(long * tab,long len) {
  long i;
  long x;
  long j;
  for(i = 1;i<len;i++){
    x = tab[i];
    j = i;
    while (j>0&&tab[j-1]>x){
      tab[j] = tab[j-1];
      j--;
      }
    tab[j] = x;
    }
}

void gene_rand(long * tab,long maxi,long len) {
  long i;
  for(i = 0;i<len;i++){
    tab[i] = rand()%maxi;
    }
}

long * sum_tab(long * tab1,long * tab2,long len) {
  long * tab = malloc(sizeof(tab1));
  long i;
  for(i = 0;i<len;i++){
    tab[i] = tab1[i]+tab2[i];
    }
  return tab;
}

void print_tab(long * tab,long len) {
  long i;
  for(i = 0;i<len;i++){
    printf("%ld ",tab[i]);
    }
  printf("\n");
}

void main() {
  srand(time(NULL));
  long * tab1 = malloc(sizeof(long)*L_TAB);
  long * tab2 = malloc(sizeof(long)*L_TAB);
  long * tab3 = malloc(sizeof(long)*L_TAB);
  gene_rand(tab1,MAX,L_TAB);
  gene_rand(tab2,MAX,L_TAB);
  partitionning(tab1,L_TAB,L_TAB);
  partitionning(tab2,L_TAB,L_TAB);
  sort_insert(tab1,L_TAB);
  sort_insert(tab2,L_TAB);
  tab3 = sum_tab(tab1,tab2,L_TAB);
}
