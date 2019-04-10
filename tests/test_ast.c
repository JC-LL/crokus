#include <stdio.h>
#include <stdlib.h>

// this is a comment

/* this is a in_comment */

/* this is a in_comment
  that uses several lines
  ...
*/

struct im{
  float a;
  float b;
};

typedef struct {
  int c;
  int d;
} paire_t;

int plus(int a,int b){
    return a+b*b;
}

int main(void){
  int a,y;
  int b=5;
  int *ptr;
  int t[100]= {0,1,2};
  int i;

  struct imag{
    unsigned int a;
    float b;
  } v1,v2[2] = {
    {1 , 2.0},
    {3 , 4.4}
  };

  y = a<b+1;

  // casting
  y   = (int) (a+b);
  ptr = (int *) &a;
  ptr = 123 + (int *) &a;

  // function call
  a=plus(a,b);

  for(i=0;i<10;i++){
     y=a+42;
     y+=b;
  }

  while(1){
    puts("cool");
  }

  if(a>b){
    printf("hey!");
  }
  else{
    printf("again!");
  }

  switch(a){
    case 1:
      puts("joli");
      break;
    case 2:
      a+=1;
      break;
    default:
      y=0;
  }

  return 0;
}
