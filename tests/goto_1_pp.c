#include <stdio.h>
#include <string.h>

int main() {
  char name[64];
  char url[80];
  char * pName;
  int x;
  pName = name;
  printf("\nWrite the name of a web page (Without www, http, .com) ");
  gets(name);
  for(x = 0;x<=strlen(name);x++)
    if (*pName+0=='\0'||*pName+x==' ') {{
      printf("Name blank or with spaces!");
      getch();
      system("cls");
      goto INPUT;
      }
    }
  strcpy(url,"http://www.");
  strcat(url,name);
  strcat(url,".com");
  printf("%s",url);
  return 0;
}
