#include<stdio.h>

int f2(int a,int b){
  int x,y;
  int i;
  int t[100];

  x=2*a+b;
  y=3*b;

  while(x<100){
    x+=1;
    if(x<5){
      x-=3;
      if (a>0){
        x++;
      }
      else{
        x*=2;
      }
    }
    else{
      while(x<100 & x>=0){
        x+=4;
        for(i=0;i<30;i++){
          y+=5;
        }
      }
    }
  }
  printf("ending\n");
  return x+y;
}

int main(){
  int x=f2(12,34);
  printf("result = %d\n",x );
  return 0;
}
