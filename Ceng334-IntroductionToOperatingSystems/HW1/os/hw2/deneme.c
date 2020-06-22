#include <stdlib.h>
#include <stdio.h>
void helper(int* array);
int main(int argc, char *argv[])
{
  int argv1=atoi(argv[1]);
  int argv2=atoi(argv[2]);
  int argv3=atoi(argv[3]);
  printf("argv1:%d argv2:%d argv3:%d\n",argv1,argv2,argv3);
  int* p=malloc(sizeof(int)*4);
  int* h;
  h=p;
  *p=1;
  *(p+1)=2;
  *(p+2)=3;
  *(p+3)=4;
  printf("*h:%d*p:%d\n",*h,*p);
  p++;
  printf("*h:%d*p:%d\n",*h,*p);
  p++;
  printf("*h:%d*p:%d\n",*h,*p);
  helper(p);
  p++;
  p++;
  p++;
  p++;
  p++;
  p++;
}
void helper(int* p)
{
  int* pointer;
  //printf("%d",sizeof(p));
  //helperhelper(pointer);
}
