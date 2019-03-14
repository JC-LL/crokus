#include<stdio.h>
struct im {
  int a;
  int b;
} v;

typedef struct {
  int c;
  int d;
} paire_t;

int main(void){
  int a,b,c;
  int y;
  int t[10];
  paire_t paire = {1,2};
  paire_t *p;

  y = a*b+c;       //expression
  y = (int )(a+b); //cast
  y = t[2+3];      //array
  y = v.a;         //pointed notation
  p = &paire;      //addressof
  y = p->c;        //access to pointer struct element
  puts("leaving");
  
  return 0;
}
