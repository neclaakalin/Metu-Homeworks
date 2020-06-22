#include "do_not_submit.h"
#include <pthread.h>
#include <semaphore.h>

typedef enum {Tired,Carrying,NotCarrying} Antstate;

typedef struct Coordinate
{
  int x;
  int y;
}Coordinate;

typedef struct Ant
{
  int id;
  Antstate state;
  Coordinate coordinate;
}Ant;

int barrierflag=1;
int currentsleepers=0;
int shouldrun=1;
int mytime;
pthread_t self;
pthread_t tid;
pthread_t *pidt;
sem_t currentsaver;
sem_t barrier;
sem_t *threads;
sem_t allcells[GRIDSIZE][GRIDSIZE];
Coordinate invalid;
void wakeup();
void gosleep();
void antmadedecision(Ant* myant,Coordinate destination);
void* antmove(Ant* myant);
void* timer(void* nullptr);
int numberofelement(Coordinate* coordinate);
bool contains(int x,int y,char search);
Coordinate* cellmaker(Coordinate coordinate,char search);
Ant makeant(int _id,Antstate _state,Coordinate _coordinate);
Coordinate makecoordinate(int x,int y);

void gosleep()
{
  sem_wait(&currentsaver);
  if (currentsleepers<getSleeperN())
  {
    currentsleepers++;
  }
  sem_post(&currentsaver);
  sem_wait(&threads[currentsleepers-1]);
}

void wakeup()
{
  sem_wait(&currentsaver);
  if (currentsleepers>getSleeperN())
  {
    currentsleepers--;
  }
  sem_post(&currentsaver);
  sem_post(&threads[currentsleepers]);
}

void* timer(void* nullptr)
{
  sleep(mytime);
  shouldrun=0;
  pthread_join(self,NULL);
}

Ant makeant(int _id,Antstate _state,Coordinate _coordinate)
{
  Ant newant;
  newant.id=_id;
  newant.state=_state;
  newant.coordinate=_coordinate;
  return newant;
}

int numberofelement(Coordinate* coordinate)
{
  int i;
  for(i=0;i<8;i++)
  {
    if (((*(coordinate+i)).x==invalid.x) && (((*(coordinate+i)).y==invalid.y)))
    {
      return i;
    }
  }
  return i;
}

Coordinate makecoordinate(int x,int y)
{
  Coordinate coordinate;
  coordinate.x=x;
  coordinate.y=y;
  return coordinate;
}

bool contains(int x,int y,char search)
{
  return (lookCharAt(x,y)==search);
}

Coordinate* cellmaker(Coordinate coordinate,char search)
{
  Coordinate* cells=malloc(sizeof(coordinate)*8);
  int result=0;
  int x=coordinate.x;
  int y=coordinate.y;
  if (x<GRIDSIZE-1 && y<GRIDSIZE-1)
  {
    if (contains(x+1,y+1,search))
    {
      Coordinate valid=makecoordinate(x+1,y+1);
      *cells=valid;
      result++;
      cells++;
    }
  }
  if (x<GRIDSIZE-1 && y>0)
  {
    if (contains(x+1,y-1,search))
    {
      Coordinate valid=makecoordinate(x+1,y-1);
      *cells=valid;
      result++;
      cells++;
    }
  }
  if (x<GRIDSIZE-1)
  {
    if (contains(x+1,y,search))
    {
      Coordinate valid=makecoordinate(x+1,y);
      *cells=valid;
      result++;
      cells++;
    }
  }
  if (x>0)
  {
    if (contains(x-1,y,search))
    {
      Coordinate valid=makecoordinate(x-1,y);
      *cells=valid;
      result++;
      cells++;
    }
  }
  if (x>0 && y<GRIDSIZE-1)
  {
    if (contains(x-1,y+1,search))
    {
      Coordinate valid=makecoordinate(x-1,y+1);
      *cells=valid;
      result++;
      cells++;
    }
  }
  if (x>0 && y>0)
  {
    if (contains(x-1,y-1,search))
    {
      Coordinate valid=makecoordinate(x-1,y-1);
      *cells=valid;
      result++;
      cells++;
    }
  }
  if (y<GRIDSIZE-1)
  {
    if (contains(x,y+1,search))
    {
      Coordinate valid=makecoordinate(x,y+1);
      *cells=valid;
      result++;
      cells++;
    }
  }
  if (y>0)
  {
    if (contains(x,y-1,search))
    {
      Coordinate valid=makecoordinate(x,y-1);
      *cells=valid;
      result++;
      cells++;
    }
  }
  while (result!=8)
  {
    *cells=invalid;
    cells++;
    result++;
  }
  return (cells-result);
}

void* antmove(Ant* myant)
{
  sem_wait(&barrier);
  sem_post(&barrier);
  while(shouldrun)
  {
    usleep(getDelay() * 1000 + (rand() % 5000));
    int myantx=myant->coordinate.x;
    int myanty=myant->coordinate.y;
    if (myant->id<getSleeperN())
    {
      sem_wait(&allcells[myant->coordinate.x][myant->coordinate.y]);
      if(myant->state==Tired || myant->state==NotCarrying)
      {
        putCharTo(myantx,myanty,'S');
      }
      if(myant->state==Carrying)
      {
        putCharTo(myantx,myanty,'$');
      }
      sem_post(&allcells[myant->coordinate.x][myant->coordinate.y]);
      gosleep();
      sem_wait(&allcells[myant->coordinate.x][myant->coordinate.y]);
      if(myant->state==Tired || myant->state==NotCarrying)
      {
        putCharTo(myantx,myanty,'1');
      }
      if(myant->state==Carrying)
      {
        putCharTo(myantx,myanty,'P');
      }
      sem_post(&allcells[myant->coordinate.x][myant->coordinate.y]);
    }
    if (getSleeperN()<currentsleepers)
    {
      wakeup();
    }
    Coordinate* emptycells=cellmaker(myant->coordinate,'-');
    Coordinate* foods=cellmaker(myant->coordinate,'o');
    int numberofemptycells=numberofelement(emptycells);
    int numberoffoods=numberofelement(foods);
    int i;
    if (myant->state==Tired)
    {
      if (numberofemptycells)
      {
        int index=rand()%numberofemptycells;
        Coordinate destination=*(emptycells+index);
        if (sem_trywait(&allcells[destination.x][destination.y])==0)
        {
          putCharTo(myant->coordinate.x,myant->coordinate.y,'-');
          putCharTo(destination.x,destination.y,'1');
          myant->coordinate=destination;
          myant->state=NotCarrying;
          sem_post(&allcells[destination.x][destination.y]);
        }
      }
      free(emptycells);
      free(foods);
      continue;
    }
    if (myant->state==Carrying)
    {
      if(numberoffoods && numberofemptycells)
      {
        int index=rand()%numberofemptycells;
        Coordinate destination=*(emptycells+index);
        if (sem_trywait(&allcells[destination.x][destination.y])==0)
        {
          putCharTo(myant->coordinate.x,myant->coordinate.y,'o');
          putCharTo(destination.x,destination.y,'1');
          myant->state=Tired;
          myant->coordinate=destination;
          sem_post(&allcells[destination.x][destination.y]);
        }
        free(emptycells);
        free(foods);
        continue;
      }
      if (numberofemptycells)
      {
        int index=rand()%numberofemptycells;
        Coordinate destination=*(emptycells+index);
        if (sem_trywait(&allcells[destination.x][destination.y])==0)
        {
          putCharTo(myant->coordinate.x,myant->coordinate.y,'-');
          putCharTo(destination.x,destination.y,'P');
          myant->coordinate=destination;
          sem_post(&allcells[destination.x][destination.y]);
        }
        free(emptycells);
        free(foods);
        continue;
      }
    }
    if (myant->state==NotCarrying)
    {
      if(numberoffoods)
      {
        int index=rand()%numberoffoods;
        Coordinate destination=*(foods+index);
        if (sem_trywait(&allcells[destination.x][destination.y])==0)
        {
          putCharTo(myant->coordinate.x,myant->coordinate.y,'-');
          putCharTo(destination.x,destination.y,'P');
          myant->coordinate=destination;
          myant->state=Carrying;
          sem_post(&allcells[destination.x][destination.y]);
        }
        free(emptycells);
        free(foods);
        continue;
      }
      if (numberofemptycells)
      {
        int index=rand()%numberofemptycells;
        Coordinate destination=*(emptycells+index);
        if (sem_trywait(&allcells[destination.x][destination.y])==0)
        {
          putCharTo(myant->coordinate.x,myant->coordinate.y,'-');
          putCharTo(destination.x,destination.y,'1');
          myant->coordinate=destination;
          sem_post(&allcells[destination.x][destination.y]);
        }
        free(emptycells);
        free(foods);
      }
    }
  }
  pthread_join(self,NULL);
}

int main(int argc, char *argv[])
{
  srand(time(NULL));
  int antnumber=atoi(argv[1]);
  int foodnumber=atoi(argv[2]);
  mytime=atoi(argv[3]);
  invalid=makecoordinate(-1,-1);
  pidt=malloc(sizeof(pthread_t)*antnumber);
  Ant* ants=malloc(sizeof(Ant)*antnumber);
  self=pthread_self();
  int i,j;
  int x,y;
  for (i=0;i<GRIDSIZE;i++)
  {
    for (j=0;j<GRIDSIZE;j++)
    {
      putCharTo(i,j,'-');
    }
  }
  for (i=0;i<GRIDSIZE;i++)
  {
      for (j=0;j<GRIDSIZE;j++)
      {
        sem_init(&allcells[i][j],0,1);
      }
  }
  threads=malloc(sizeof(sem_t)*antnumber);
  sem_init(&currentsaver,0,1);
  sem_init(&barrier,0,0);
  pthread_create(&tid,NULL,timer,NULL);
  for (i=0;i<antnumber;i++)
  {
    do
    {
      x=rand()%GRIDSIZE;
      y=rand()%GRIDSIZE;
    } while(lookCharAt(x,y)=='1');
      Ant myant=makeant(i,NotCarrying,makecoordinate(x,y));
      ants[i]=myant;
      pthread_create(&pidt[i],NULL,antmove,(ants+i));
      putCharTo(x,y,'1');
  }
  for (i=0;i<antnumber;i++)
  {
    sem_init(&threads[i],0,0);
  }
  for (i=0;i<foodnumber;i++)
  {
    do
    {
      x=rand()%GRIDSIZE;
      y=rand()%GRIDSIZE;
    } while(lookCharAt(x,y)=='1' || lookCharAt(x,y)=='o');
      putCharTo(x,y,'o');
  }
  sem_post(&barrier);
  startCurses();
  char c;
  while (shouldrun)
  {
    if (currentsleepers==antnumber && getSleeperN()<currentsleepers)
    {
      wakeup();
    }
    for (i=0;i<GRIDSIZE;i++)
    {
      for(j=0;j<GRIDSIZE;j++)
      {
        sem_wait(&allcells[i][j]);
      }
    }
    drawWindow();
    for (i=0;i<GRIDSIZE;i++)
    {
      for(j=0;j<GRIDSIZE;j++)
      {
        sem_post(&allcells[i][j]);
      }
    }
    //drawWindow();
    c=0;
    c=getch();
    if (c=='q' || c==ESC) break;
    if (c=='+')
    {
      setDelay(getDelay()+10);
    }
    if (c == '-')
    {
      setDelay(getDelay()-10);
    }
    if (c == '*')
    {
      if (getSleeperN()>=antnumber)
      {
        setSleeperN(antnumber);
      }
      else
      {
        setSleeperN(getSleeperN()+1);
      }
    }
    if (c == '/')
    {
      setSleeperN(getSleeperN()-1);
    }
      usleep(DRAWDELAY);
  }
  endCurses();
  free(threads);
  free(pidt);
  free(ants);
  return 0;
}
