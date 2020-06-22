#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <poll.h>
#include <limits.h>
#define PIPE(fd) socketpair(AF_UNIX, SOCK_STREAM, PF_UNIX, fd)
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

typedef struct hunter
{
  coordinate pos;
  int energy;
}hunter;

typedef struct prey
{
  coordinate pos;
  int energy;
}prey;

typedef struct obstacle
{
  coordinate pos;
}obstacle;
void printboard(char **map,int ycoord,int xcoord);
int isrunning(int numberofhunters,int numberofpreys,hunter* hunters,prey* preys);
int main(int argc, char** argv)
{
  int xcoord,ycoord;
  int xinp,yinp,energy;
  int numberofobstacles;
  int numberofhunters;
  int numberofpreys;
  int i=0,j=0;
  scanf("%d %d",&xcoord,&ycoord);
  char** map=malloc(sizeof(char*)*ycoord);
  for (i=0;i<ycoord;i++)
  {
    map[i]=malloc(sizeof(char)*xcoord);
  }
  int hunter_count=0;
  int prey_count=0;
  int obstacle_count=0;
  for (i=0;i<ycoord;i++)
  {
    for (j=0;j<xcoord;j++)
    {
      map[i][j]=' ';
    }
  }
  scanf("%d",&numberofobstacles);
  obstacle* obstacles=malloc(sizeof(obstacle)*numberofobstacles);
  while (obstacle_count<numberofobstacles)
  {
    scanf("%d %d",&yinp,&xinp);
    obstacles[obstacle_count].pos.x=xinp;
    obstacles[obstacle_count].pos.y=yinp;
    obstacle_count++;
    map[yinp][xinp]='X';
  }
  scanf("%d",&numberofhunters);
  hunter* hunters=malloc(sizeof(hunter)*numberofhunters);
  while (hunter_count<numberofhunters)
  {
    i++;
    scanf("%d %d %d",&yinp,&xinp,&energy);
    hunters[hunter_count].pos.x=xinp;
    hunters[hunter_count].pos.y=yinp;
    hunters[hunter_count].energy=energy;
    hunter_count++;
    map[yinp][xinp]='H';
  }
  scanf("%d",&numberofpreys);
  prey* preys=malloc(sizeof(prey)*numberofpreys);
  while (prey_count<numberofpreys)
  {
    scanf("%d %d %d",&yinp,&xinp,&energy);
    preys[prey_count].pos.x=xinp;
    preys[prey_count].pos.y=yinp;
    preys[prey_count].energy=energy;
    prey_count++;
    map[yinp][xinp]='P';
  }
  printboard(map,ycoord,xcoord);
  char* arr[3];
  struct pollfd fds[numberofhunters+numberofpreys];
  arr[0]=malloc(sizeof(char)*30);
  arr[1]=malloc(sizeof(char)*30);
  arr[2]=NULL;
  snprintf(arr[0],sizeof(arr[0]),"%d",xcoord);
  snprintf(arr[1],sizeof(arr[1]),"%d",ycoord);
  int** fd=malloc(sizeof(int *)*(numberofhunters+numberofpreys));
  pid_t* process=malloc(sizeof(pid_t)*(numberofhunters+numberofpreys));
  for (i=0;i<numberofhunters+numberofpreys;i++)
  {
    fd[i]=malloc(sizeof(int)*2);
  }
  for (i=0;i<numberofhunters+numberofpreys;i++)
  {
    PIPE(fd[i]);
  }
  for (i=0;i<numberofhunters;i++)
  {
    server_message fromsv;
    coordinate closest;
    int distance,shortestdistance,objects=0;
    shortestdistance=INT_MAX;
    for (j=0;j<numberofpreys;j++)
    {
      distance=abs(hunters[i].pos.x-preys[j].pos.x)+abs(hunters[i].pos.y-preys[j].pos.y);
      if (distance<shortestdistance)
      {
        shortestdistance=distance;
        closest.x=preys[j].pos.x;
        closest.y=preys[j].pos.y;
      }
    }
    if (hunters[i].pos.y>0 && (map[hunters[i].pos.y-1][hunters[i].pos.x]==88 || map[hunters[i].pos.y-1][hunters[i].pos.x]==72))
    {
      fromsv.object_pos[objects].y=hunters[i].pos.y-1;
      fromsv.object_pos[objects++].x=hunters[i].pos.x;
    }
    if (hunters[i].pos.x>0 && (map[hunters[i].pos.y][hunters[i].pos.x-1]==88 || map[hunters[i].pos.y][hunters[i].pos.x-1]==72))
    {
      fromsv.object_pos[objects].y=hunters[i].pos.y;
      fromsv.object_pos[objects++].x=hunters[i].pos.x-1;
    }
    if (hunters[i].pos.y<ycoord-1 && (map[hunters[i].pos.y+1][hunters[i].pos.x]==88 || map[hunters[i].pos.y+1][hunters[i].pos.x]==72))
    {
      fromsv.object_pos[objects].y=hunters[i].pos.y+1;
      fromsv.object_pos[objects++].x=hunters[i].pos.x;
    }
    if (hunters[i].pos.x<xcoord-1 && (map[hunters[i].pos.y][hunters[i].pos.x+1]==88 || map[hunters[i].pos.y][hunters[i].pos.x+1]==72))
    {
      fromsv.object_pos[objects].y=hunters[i].pos.y;
      fromsv.object_pos[objects++].x=hunters[i].pos.x+1;
    }
    fromsv.object_count=objects;
    fromsv.pos.x=hunters[i].pos.x;
    fromsv.pos.y=hunters[i].pos.y;
    fromsv.adv_pos.x=closest.x;
    fromsv.adv_pos.y=closest.y;
    pid_t pid1=fork();
    if (pid1==0)
    {
      int k;
      for(k=0;k<numberofhunters+numberofpreys;k++)
      {
        if(k!=i)
        {
          close(fd[k][0]);
          close(fd[k][1]);
        }
      }
      close(fd[i][0]);
      dup2(fd[i][1],0);
      dup2(fd[i][1],1);
      execv("hunter",arr);
    }
    process[i]=pid1;
    write(fd[i][0],&fromsv,sizeof(server_message));
  }
  for (i=0;i<numberofpreys;i++)
  {
    server_message fromsv;
    coordinate closest;
    int distance,shortestdistance,objects=0;
    shortestdistance=INT_MAX;
    for (j=0;j<numberofhunters;j++)
    {
      distance=abs(preys[i].pos.x-hunters[j].pos.x)+abs(preys[i].pos.y-hunters[j].pos.y);
      if (distance<shortestdistance)
      {
        shortestdistance=distance;
        closest.x=hunters[j].pos.x;
        closest.y=hunters[j].pos.y;
      }
    }
    if (preys[i].pos.y>0 && (map[preys[i].pos.y-1][preys[i].pos.x]!=32 && map[preys[i].pos.y-1][preys[i].pos.x]!=72))
    {
      fromsv.object_pos[objects].y=preys[i].pos.y-1;
      fromsv.object_pos[objects++].x=preys[i].pos.x;
    }
    if (preys[i].pos.x>0 && (map[preys[i].pos.y][preys[i].pos.x-1]!=32 && map[preys[i].pos.y][preys[i].pos.x-1]!=72))
    {
      fromsv.object_pos[objects].y=preys[i].pos.y;
      fromsv.object_pos[objects++].x=preys[i].pos.x-1;
    }
    if (preys[i].pos.y<ycoord-1 && (map[preys[i].pos.y+1][preys[i].pos.x]!=32 && map[preys[i].pos.y+1][preys[i].pos.x]!=72))
    {
      fromsv.object_pos[objects].y=preys[i].pos.y+1;
      fromsv.object_pos[objects++].x=preys[i].pos.x;
    }
    if (preys[i].pos.x<xcoord-1 && (map[preys[i].pos.y][preys[i].pos.x+1]!=32 && map[preys[i].pos.y][preys[i].pos.x+1]!=72))
    {
      fromsv.object_pos[objects].y=preys[i].pos.y;
      fromsv.object_pos[objects++].x=preys[i].pos.x+1;
    }
    fromsv.object_count=objects;
    fromsv.pos.x=preys[i].pos.x;
    fromsv.pos.y=preys[i].pos.y;
    fromsv.adv_pos=closest;
    pid_t pid1=fork();
    if (pid1==0)
    {
      int k;
      for(k=0;k<numberofhunters+numberofpreys;k++)
      {
        if(k!=numberofhunters+i)
        {
          close(fd[k][0]);
          close(fd[k][1]);
        }
      }
      close(fd[numberofhunters+i][0]);
      dup2(fd[numberofhunters+i][1],0);
      dup2(fd[numberofhunters+i][1],1);

      if(execv("prey",arr) < 0) {
        printf("ERROR: Couldn't execute the bidder. i: %d\n", i);
      }
    }
    process[numberofhunters+i]=pid1;
    write(fd[numberofhunters+i][0],&fromsv,sizeof(server_message));
  }
  for (i=0;i<numberofpreys+numberofhunters;i++)
  {
    fds[i].fd=fd[i][0];
    fds[i].events=POLLIN;
    fds[i].revents=0;
  }
  while(isrunning(numberofhunters,numberofpreys,hunters,preys))
  {
    ph_message fromph;
    server_message fromsv;
    poll(fds,numberofhunters+numberofpreys,0);
    for (i=0;i<numberofhunters+numberofpreys;i++)
    {
      if (fds[i].revents &&POLLIN)
      {
        if (i<numberofhunters && hunters[i].energy!=0)
        {
          if(!isrunning(numberofhunters,numberofpreys,hunters,preys))
          {
            goto out;
          }
          read(fds[i].fd,&fromph,sizeof(ph_message));
          if (map[fromph.move_request.y][fromph.move_request.x]==map[hunters[i].pos.y][hunters[i].pos.x])
          {
            goto hunterwrite;
          }
          if (map[fromph.move_request.y][fromph.move_request.x]==72)
          {
            goto hunterwrite;
          }
          if (map[fromph.move_request.y][fromph.move_request.x]==80)
          {
            hunters[i].energy--;
            int k;
            for (k=0;k<numberofpreys;k++)
            {
              if(preys[k].pos.y==fromph.move_request.y && preys[k].pos.x==fromph.move_request.x)
              {
                hunters[i].energy+=preys[k].energy;
                preys[k].energy=0;
                kill(process[numberofhunters+k],SIGTERM);
                waitpid(process[numberofhunters+k],0,0);
                close(fd[numberofhunters+k][0]);
                close(fd[numberofhunters+k][1]);
              }
            }
            map[hunters[i].pos.y][hunters[i].pos.x]=32;
            map[fromph.move_request.y][fromph.move_request.x]=72;
            hunters[i].pos.y=fromph.move_request.y;
            hunters[i].pos.x=fromph.move_request.x;
            printboard(map,ycoord,xcoord);
            if(!isrunning(numberofhunters,numberofpreys,hunters,preys))
            {
              goto out;
            }
            goto hunterwrite;
          }
          if (map[fromph.move_request.y][fromph.move_request.x]==32)
          {
            hunters[i].energy--;
            map[hunters[i].pos.y][hunters[i].pos.x]=32;
            map[fromph.move_request.y][fromph.move_request.x]=72;
            hunters[i].pos.y=fromph.move_request.y;
            hunters[i].pos.x=fromph.move_request.x;
            printboard(map,ycoord,xcoord);;
            goto hunterwrite;
          }
          hunterwrite:
          if (hunters[i].energy==0)
          {
            kill(process[i],SIGTERM);
            waitpid(process[i],0,0);
            close(fd[i][0]);
            close(fd[i][1]);
            map[hunters[i].pos.y][hunters[i].pos.x]=32;
            printboard(map,ycoord,xcoord);
            if(!isrunning(numberofhunters,numberofpreys,hunters,preys))
            {
              goto out;
            }
            continue;
          }
          coordinate closest;
          int distance,shortestdistance,objects=0;
          shortestdistance=INT_MAX;
          for (j=0;j<numberofpreys;j++)
          {
            if (preys[j].energy==0)
            {
              continue;
            }
            distance=abs(hunters[i].pos.x-preys[j].pos.x)+abs(hunters[i].pos.y-preys[j].pos.y);
            if (distance<shortestdistance)
            {
              shortestdistance=distance;
              closest.x=preys[j].pos.x;
              closest.y=preys[j].pos.y;
            }
          }
          if (hunters[i].pos.y>0 && (map[hunters[i].pos.y-1][hunters[i].pos.x]==88 || map[hunters[i].pos.y-1][hunters[i].pos.x]==72))
          {
            fromsv.object_pos[objects].y=hunters[i].pos.y-1;
            fromsv.object_pos[objects++].x=hunters[i].pos.x;
          }
          if (hunters[i].pos.x>0 && (map[hunters[i].pos.y][hunters[i].pos.x-1]==88 || map[hunters[i].pos.y][hunters[i].pos.x-1]==72))
          {
            fromsv.object_pos[objects].y=hunters[i].pos.y;
            fromsv.object_pos[objects++].x=hunters[i].pos.x-1;
          }
          if (hunters[i].pos.y<ycoord-1 && (map[hunters[i].pos.y+1][hunters[i].pos.x]==88 || map[hunters[i].pos.y+1][hunters[i].pos.x]==72))
          {
            fromsv.object_pos[objects].y=hunters[i].pos.y+1;
            fromsv.object_pos[objects++].x=hunters[i].pos.x;
          }
          if (hunters[i].pos.x<xcoord-1 && (map[hunters[i].pos.y][hunters[i].pos.x+1]==88 || map[hunters[i].pos.y][hunters[i].pos.x+1]==72))
          {
            fromsv.object_pos[objects].y=hunters[i].pos.y;
            fromsv.object_pos[objects++].x=hunters[i].pos.x+1;
          }
          fromsv.object_count=objects;
          fromsv.pos.x=hunters[i].pos.x;
          fromsv.pos.y=hunters[i].pos.y;
          fromsv.adv_pos=closest;
          if(!isrunning(numberofhunters,numberofpreys,hunters,preys))
          {
            goto out;
          }
          write(fds[i].fd,&fromsv,sizeof(server_message));
        }
        if(i>=numberofhunters && preys[i-numberofhunters].energy!=0)
        {
          read(fd[i][0],&fromph,sizeof(ph_message));
          if (map[fromph.move_request.y][fromph.move_request.x]==map[preys[i-numberofhunters].pos.y][preys[i-numberofhunters].pos.x])
          {
            goto preywrite;
          }
          if (map[fromph.move_request.y][fromph.move_request.x]==72)
          {
            goto preywrite;
          }
          if (map[fromph.move_request.y][fromph.move_request.x]==80)
          {
            int k;
            for(k=0;k<numberofhunters;k++)
            {
              if(fromph.move_request.x==hunters[k].pos.x && fromph.move_request.y==hunters[k].pos.y)
              {
                hunters[k].energy+=preys[i-numberofhunters].energy;
                map[preys[i-numberofhunters].pos.y][preys[i-numberofhunters].pos.x]=32;
                preys[i-numberofhunters].energy=0;
                preys[i-numberofhunters].pos.y=fromph.move_request.y;
                preys[i-numberofhunters].pos.x=fromph.move_request.x;
                kill(process[i],SIGTERM);
                waitpid(process[i],0,0);
                close(fd[i][0]);
                close(fd[i][1]);
                printboard(map,ycoord,xcoord);
                if(!isrunning(numberofhunters,numberofpreys,hunters,preys))
                {
                  goto out;
                }
              }
            }
            continue;
          }
          if (map[fromph.move_request.y][fromph.move_request.x]==32)
          {
            map[preys[i-numberofhunters].pos.y][preys[i-numberofhunters].pos.x]=32;
            map[fromph.move_request.y][fromph.move_request.x]=80;
            preys[i-numberofhunters].pos.y=fromph.move_request.y;
            preys[i-numberofhunters].pos.x=fromph.move_request.x;
            printboard(map,ycoord,xcoord);
          }
          preywrite:
          ;
          coordinate closest;
          int distance,shortestdistance,objects=0;
          shortestdistance=INT_MAX;
          for (j=0;j<numberofhunters;j++)
          {
            if (hunters[j].energy==0)
            {
              continue;
            }
            distance=abs(preys[i-numberofhunters].pos.x-hunters[j].pos.x)+abs(preys[i-numberofhunters].pos.y-hunters[j].pos.y);
            if (distance<shortestdistance)
            {
              shortestdistance=distance;
              closest.x=hunters[j].pos.x;
              closest.y=hunters[j].pos.y;
            }
          }
          if (preys[i-numberofhunters].pos.y>0 && (map[preys[i-numberofhunters].pos.y-1][preys[i-numberofhunters].pos.x]!=32 && map[preys[i-numberofhunters].pos.y-1][preys[i-numberofhunters].pos.x]!=72))
          {
            fromsv.object_pos[objects].y=preys[i-numberofhunters].pos.y-1;
            fromsv.object_pos[objects++].x=preys[i-numberofhunters].pos.x;
          }
          if (preys[i-numberofhunters].pos.x>0 && (map[preys[i-numberofhunters].pos.y][preys[i-numberofhunters].pos.x-1]!=32 && map[preys[i-numberofhunters].pos.y][preys[i-numberofhunters].pos.x-1]!=72))
          {
            fromsv.object_pos[objects].y=preys[i-numberofhunters].pos.y;
            fromsv.object_pos[objects++].x=preys[i-numberofhunters].pos.x-1;
          }
          if (preys[i-numberofhunters].pos.y<ycoord-1 && (map[preys[i-numberofhunters].pos.y+1][preys[i-numberofhunters].pos.x]!=32 && map[preys[i-numberofhunters].pos.y+1][preys[i-numberofhunters].pos.x]!=72))
          {
            fromsv.object_pos[objects].y=preys[i-numberofhunters].pos.y+1;
            fromsv.object_pos[objects++].x=preys[i-numberofhunters].pos.x;
          }
          if (preys[i-numberofhunters].pos.x<xcoord-1 && (map[preys[i-numberofhunters].pos.y][preys[i-numberofhunters].pos.x+1]!=32 && map[preys[i-numberofhunters].pos.y][preys[i-numberofhunters].pos.x+1]!=72))
          {
            fromsv.object_pos[objects].y=preys[i-numberofhunters].pos.y;
            fromsv.object_pos[objects++].x=preys[i-numberofhunters].pos.x+1;
          }
          fromsv.object_count=objects;
          fromsv.pos.x=preys[i-numberofhunters].pos.x;
          fromsv.pos.y=preys[i-numberofhunters].pos.y;
          fromsv.adv_pos=closest;
          if(!isrunning(numberofhunters,numberofpreys,hunters,preys))
          {
            goto out;
          }
          write(fds[i].fd,&fromsv,sizeof(server_message));
        }
      }
    }
  }
  out:
  for (i=0;i<numberofhunters+numberofpreys;i++)
  {
    kill(process[i],SIGTERM);
    waitpid(process[i],0,0);
    close(fd[i][0]);
    close(fd[i][1]);
  }
  return 0;
}
int isrunning(int numberofhunters,int numberofpreys,hunter* hunters,prey* preys)
{
  int i;
  int result1=0,result2=0;
  int result;
  for(i=0;i<numberofhunters;i++)
  {
    if (hunters[i].energy!=0)
    {
      result1=1;
      break;
    }
  }
  for(i=0;i<numberofpreys;i++)
  {
    if (preys[i].energy!=0)
    {
      result2=1;
      break;
    }
  }
  result=result1 && result2;
  return result;
}
void printboard(char ** map,int ycoord,int xcoord)
{
  int i,j;
  printf("+");
  for(i=0;i<xcoord;i++)
  {
    printf("-");
  }
  printf("+\n");
  for(i=0;i<ycoord;i++)
  {
    printf("|");
    for(j=0;j<xcoord;j++)
    {
      printf("%c",map[i][j]);
    }
    printf("|\n");
  }
  printf("+");
  for(i=0;i<xcoord;i++)
  {
    printf("-");
  }
  printf("+\n");
}
