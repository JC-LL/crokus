#include <stdio.h>
#include <stdlib.h>

int plus(int a,int b){
    return a+b;
}

int main(void){
  int a,y;
  int b=5;
  int *ptr;
  int t[100]= {0,1,2};

  struct imag{
    unsigned int a;
    float b;
  } v1,v2[2] = {
    {1 , 2.0},
    {3 , 4.4}
  };

  y = a<b+1;


  y   = (int) (a+b);
  ptr = (int *) &a;

  plus(a,b);

  for(int i=0;i<10;i++){
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

  return 0;
}
