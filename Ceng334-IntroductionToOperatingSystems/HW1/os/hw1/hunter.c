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
    server_message fromsv;
    ph_message fromhunter;
    read(0,&fromsv,sizeof(server_message));
    fromhunter.move_request.x=fromsv.pos.x;
    fromhunter.move_request.y=fromsv.pos.y;
    int flagxd=1,flagxa=1,flagyw=1,flagys=1;
    int shortest_distance=abs(fromsv.pos.y-fromsv.adv_pos.y)+abs(fromsv.pos.x-fromsv.adv_pos.x);
    int distance=0,i;
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
      distance=abs(fromsv.pos.y-1-fromsv.adv_pos.y)+abs(fromsv.pos.x-fromsv.adv_pos.x);
      {
        if (shortest_distance>distance)
        {
          fromhunter.move_request.y=fromsv.pos.y-1;
          fromhunter.move_request.x=fromsv.pos.x;
        }
      }
    }
    if (flagys)
    {
      distance=abs(fromsv.pos.y+1-fromsv.adv_pos.y)+abs(fromsv.pos.x-fromsv.adv_pos.x);
      {
        if (shortest_distance>distance)
        {
          fromhunter.move_request.y=fromsv.pos.y+1;
          fromhunter.move_request.x=fromsv.pos.x;
        }
      }
    }
    if (flagxd)
    {
      distance=abs(fromsv.pos.y-fromsv.adv_pos.y)+abs(fromsv.pos.x+1-fromsv.adv_pos.x);
      {
        if (shortest_distance>distance)
        {
          fromhunter.move_request.y=fromsv.pos.y;
          fromhunter.move_request.x=fromsv.pos.x+1;
        }
      }
    }
    if (flagxa)
    {
      distance=abs(fromsv.pos.y-fromsv.adv_pos.y)+abs(fromsv.pos.x-1-fromsv.adv_pos.x);
      {
        if (shortest_distance>distance)
        {
          fromhunter.move_request.y=fromsv.pos.y;
          fromhunter.move_request.x=fromsv.pos.x-1;
        }
      }
    }
    //fprintf(stderr,"hunter:y:%dx:%d\n",fromhunter.move_request.y,fromhunter.move_request.x);
    usleep(10000*(1+rand()%9));
    write(1,&fromhunter,sizeof(ph_message));
  }
}
