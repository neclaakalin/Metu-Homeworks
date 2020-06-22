#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>
typedef struct coordinate
{
int x;
int y;
}coordinate;

typedef struct server_message
{
coordinate pos;
coordinate adv_pos;
int object_count;
coordinate object_pos[4];
}server_message;

typedef struct ph_message
{
coordinate move_request;
}ph_message;
int main(int argc,char* argv[])
{
  while(1)
  {
    int heigth=atoi(argv[1]);
    int width=atoi(argv[0]);
    server_message fromsv;
    ph_message fromprey;
    read(0,&fromsv,sizeof(server_message));
    fromprey.move_request.y=fromsv.pos.y;
    fromprey.move_request.x=fromsv.pos.x;
    int flagxd=1,flagxa=1,flagyw=1,flagys=1;
    int max_distance=abs(fromsv.pos.y-fromsv.adv_pos.y)+abs(fromsv.pos.x-fromsv.adv_pos.x);
    //fprintf(stderr, "MY:::y:%dx:%d\n",fromsv.pos.y,fromsv.pos.y );
    //fprintf(stderr, "ADV::::y:%dx:%d\n",fromsv.adv_pos.y,fromsv.adv_pos.y );
    int distance=0,i;
    if (fromsv.pos.y==heigth-1)
    {
      flagys=0;
    }
    if (fromsv.pos.y==0)
    {
      flagyw=0;
    }
    if (fromsv.pos.x==width-1)
    {
      flagxd=0;
    }
    if (fromsv.pos.x==0)
    {
      flagxa=0;
    }
    for (i=0;i<fromsv.object_count;i++)
    {
        if(fromsv.object_pos[i].y>fromsv.pos.y)
        {
          flagys=0;
        }
        if(fromsv.object_pos[i].y<fromsv.pos.y)
        {
          flagyw=0;
        }
        if(fromsv.object_pos[i].x>fromsv.pos.x)
        {
          flagxd=0;
        }
        if(fromsv.object_pos[i].x<fromsv.pos.x)
        {
          flagxa=0;
        }
    }
    if (flagyw)
    {
      distance=abs(fromsv.pos.x-fromsv.adv_pos.x)+abs(fromsv.pos.y-1-fromsv.adv_pos.y);
      if(distance>max_distance)
      {
        max_distance=distance;
        fromprey.move_request.y=fromsv.pos.y-1;
        fromprey.move_request.x=fromsv.pos.x;
      }
    }
    if (flagys)
    {
      distance=abs(fromsv.pos.x-fromsv.adv_pos.x)+abs(fromsv.pos.y+1-fromsv.adv_pos.y);
      if(distance>max_distance)
      {
        max_distance=distance;
        fromprey.move_request.y=fromsv.pos.y+1;
        fromprey.move_request.x=fromsv.pos.x;
      }
    }
    if (flagxd)
    {
      distance=abs(fromsv.pos.x+1-fromsv.adv_pos.x)+abs(fromsv.pos.y-fromsv.adv_pos.y);
      if(distance>max_distance)
      {
        max_distance=distance;
        fromprey.move_request.y=fromsv.pos.y;
        fromprey.move_request.x=fromsv.pos.x+1;
      }
    }
    if (flagxa)
    {
      distance=abs(fromsv.pos.x-1-fromsv.adv_pos.x)+abs(fromsv.pos.y-fromsv.adv_pos.y);
      if(distance>max_distance)
      {
        max_distance=distance;
        fromprey.move_request.y=fromsv.pos.y;
        fromprey.move_request.x=fromsv.pos.x-1;
      }
    }
    //fprintf(stderr,"prey:y:%dx:%d\n",fromprey.move_request.y,fromprey.move_request.x);
    usleep(10000*(1+rand()%9));
    write(1,&fromprey,sizeof(ph_message));
  }
}
