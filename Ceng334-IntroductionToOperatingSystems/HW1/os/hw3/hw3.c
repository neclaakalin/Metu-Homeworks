#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "ext2.h"


#define BASE_OFFSET 1024
#define EXT2_BLOCK_SIZE 1024
#define IMAGE "image_big.img"

typedef unsigned char bmap;
#define __NBITS (8 * (int) sizeof (bmap))
#define __BMELT(d) ((d) / __NBITS)
#define __BMMASK(d) ((bmap) 1 << ((d) % __NBITS))
#define BM_SET(d, set) ((set[__BMELT (d)] |= __BMMASK (d)))
#define BM_CLR(d, set) ((set[__BMELT (d)] &= ~__BMMASK (d)))
#define BM_ISSET(d, set) ((set[__BMELT (d)] & __BMMASK (d)) != 0)

unsigned int block_size = 0;
#define BLOCK_OFFSET(block) (BASE_OFFSET + (block-1)*block_size)

int main(int argc,char* argv[])
{
  struct ext2_super_block super;
  struct ext2_group_desc group;
  int fd;

  if ((fd = open(argv[1], O_RDWR)) < 0) {
      perror(IMAGE);
      exit(1);
  }
  lseek(fd, BASE_OFFSET, SEEK_SET);
  read(fd, &super, sizeof(super));
  block_size = 1024 << super.s_log_block_size;
  lseek(fd, BASE_OFFSET + block_size, SEEK_SET);
  read(fd, &group, sizeof(group));
  struct ext2_inode inode;
  bmap* inode_bitmap;
  bmap* data_block_bitmap;
  inode_bitmap=malloc(block_size);
  data_block_bitmap=malloc(block_size);
  lseek(fd, BLOCK_OFFSET(group.bg_inode_bitmap),SEEK_SET);
  read(fd, inode_bitmap,block_size);
  lseek(fd, BLOCK_OFFSET(group.bg_block_bitmap),SEEK_SET);
  read(fd, data_block_bitmap,block_size);
  unsigned int count=0;
  unsigned int* block1=malloc(block_size);
  unsigned int* block2=malloc(block_size);
  unsigned int* block3=malloc(block_size);
  struct ext2_inode* deletedarray=malloc(sizeof(struct ext2_inode)*super.s_inodes_per_group);
  int* inodenumber=malloc(sizeof(int)*super.s_inodes_per_group);
  int* deletion=malloc(sizeof(int)*super.s_inodes_per_group);
  for (int i=0;i<super.s_inodes_per_group;i++)
  {
    *(deletion+i)=0;
  }
  for (int i = 0; i < super.s_inodes_per_group; i++)
  {
    lseek(fd, BLOCK_OFFSET(group.bg_inode_table)+sizeof(struct ext2_inode)*i,SEEK_SET);
    read(fd, &inode, sizeof(struct ext2_inode));
    if (inode.i_size>0 && !(BM_ISSET(i,inode_bitmap)))
    {
      inode.i_flags=i;
      *(deletedarray+count)=inode;
      *(inodenumber+count)=i+1;
      count++;
    }
  }
  int* realnumbers=malloc(sizeof(int)*count);
  struct ext2_inode* copyarray=malloc(sizeof(struct ext2_inode)*count);
  for(int i=0;i<count;i++)
  {
    *(copyarray+i)=*(deletedarray+i);
    *(realnumbers+i)=*(inodenumber+i);
    int temp=(*(copyarray+i)).i_blocks*(512/(float)block_size);
    if(i<9)
    {
      printf("file0%d %u %d\n",i+1,(*(copyarray+i)).i_dtime,temp);
    }
    else
    {
      printf("file%d %u %d\n",i+1,(*(copyarray+i)).i_dtime,temp);
    }
  }
  for(int i=0;i<count;i++)
  {
    if((*(deletedarray+i)).i_dtime<(*(deletedarray+i+1)).i_dtime)
    {
      struct ext2_inode tmp=*(deletedarray+i);
      int tmp2=*(inodenumber+i);
      *(deletedarray+i)=*(deletedarray+i+1);
      *(deletedarray+i+1)=tmp;
      *(inodenumber+i)=*(inodenumber+i+1);
      *(inodenumber+i+1)=tmp2;
      i=i-2;
      if (i<0)
      {
        i=0;
      }
    }
  }
  for (int i = 0; i<count; i++)
  {
    struct ext2_inode currentinode=*(deletedarray+i);
    int inodenumbers=*(inodenumber+i);
    if (currentinode.i_size>0 && !(BM_ISSET(inodenumbers-1,inode_bitmap)))
    {
      int flag=1;
      for(int j=0;j<15;j++)
      {
        if (j<=11)
        {
          if(currentinode.i_block[j]!=0 && BM_ISSET(currentinode.i_block[j]-1, data_block_bitmap))
          {
            flag=0;
            break;
          }
        }
        if (j==12)
        {
          lseek(fd,block_size*currentinode.i_block[j],SEEK_SET);
          read(fd,block1,block_size);
          for(int k=0;k<block_size/4;k++)
          {
            if(block1[k]!=0 && BM_ISSET(block1[k]-1, data_block_bitmap))
            {
              flag=0;
              break;
            }
          }
        }
        if (j==13)
        {
          lseek(fd,block_size*currentinode.i_block[j],SEEK_SET);
          read(fd,block1,block_size);
          for(int k=0;k<block_size/4;k++)
          {
            lseek(fd, block_size*block1[k], SEEK_SET);
            read(fd, block2, block_size);
            for(int l=0;l<block_size/4;l++)
            {
              if(block2[l]!=0 && BM_ISSET(block2[l]-1, data_block_bitmap))
              {
                flag=0;
                break;
              }
            }
          }
        }
        if (j==14)
        {
          lseek(fd,block_size*currentinode.i_block[j],SEEK_SET);
          read(fd,block1,block_size);
          for(int k=0;k<block_size/4;k++)
          {
            lseek(fd,block_size*block1[k],SEEK_SET);
            read(fd,block2,block_size);
            for(int l=0;l<block_size/4;l++)
            {
              lseek(fd,block_size*block2[l],SEEK_SET);
              read(fd,block3,block_size);
              for(int m=0;m<block_size/4;m++)
              {
                if(block3[m]!=0 && BM_ISSET(block3[m]-1, data_block_bitmap))
                {
                  flag=0;
                  break;
                }
              }
            }
          }
        }
      }
      if (flag)
      {
        BM_SET(inodenumbers-1,inode_bitmap);
        lseek(fd, BLOCK_OFFSET(group.bg_inode_bitmap), SEEK_SET);
        write(fd,inode_bitmap,block_size);
        for(int j=0;j<15;j++)
        {
          if (j<=11)
          {
            if(currentinode.i_block[j]!=0)
            {
              BM_SET(currentinode.i_block[j]-1,data_block_bitmap);
            }
            else
            {
              break;
            }
          }
          if (j==12)
          {
            lseek(fd,block_size*currentinode.i_block[j],SEEK_SET);
            read(fd,block1,block_size);
            if(currentinode.i_block[j]==0)
            {
              break;
            }
            else
            {
              BM_SET(currentinode.i_block[j]-1,data_block_bitmap);
              for(int k=0;k<block_size/4;k++)
              {
                if(block1[k]!=0)
                {
                  BM_SET(block1[k]-1,data_block_bitmap);
                }
                else
                {
                  break;
                }
              }
            }
          }
          if (j==13)
          {
            lseek(fd,block_size*currentinode.i_block[j],SEEK_SET);
            read(fd,block1,block_size);
            if(currentinode.i_block[j]==0)
            {
              break;
            }
            else
            {
              BM_SET(currentinode.i_block[j]-1,data_block_bitmap);
              for(int k=0;k<block_size/4;k++)
              {
                lseek(fd,block_size*block1[k],SEEK_SET);
                read(fd, block2, block_size);
                if (block1[k]==0)
                {
                  break;
                }
                BM_SET(block1[k]-1,data_block_bitmap);
                for(int l=0;l<block_size/4;l++)
                {
                  if(block2[l]!=0)
                  {
                    BM_SET(block2[l]-1,data_block_bitmap);
                  }
                  else
                  {
                    break;
                  }
                }
              }
            }
          }
          if (j==14)
          {
            lseek(fd,block_size*currentinode.i_block[j],SEEK_SET);
            read(fd,block1,block_size);
            if(currentinode.i_block[j]==0)
            {
              break;
            }
            else
            {
              BM_SET(currentinode.i_block[j]-1,data_block_bitmap);
              for(int k=0;k<block_size/4;k++)
              {
                lseek(fd,block_size*block1[k],SEEK_SET);
                read(fd,block2,block_size);
                if(block1[k]==0)
                {
                  break;
                }
                else
                {
                  BM_SET(block1[k]-1,data_block_bitmap);
                  for(int l=0;l<block_size/4;l++)
                  {
                    lseek(fd,block_size*block2[l],SEEK_SET);
                    read(fd,block3,block_size);
                    if(block2[l]==0)
                    {
                      break;
                    }
                    else
                    {
                      BM_SET(block2[l]-1,data_block_bitmap);
                      for(int m=0;m<block_size/4;m++)
                      {
                        if(block3[m]!=0)
                        {
                          BM_SET(block3[m]-1,data_block_bitmap);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        lseek(fd,BLOCK_OFFSET(group.bg_block_bitmap),SEEK_SET);
        write(fd,data_block_bitmap,block_size);
        int position=-1;
        for (int j=0;j<count;j++)
        {
          if(copyarray[j].i_flags==currentinode.i_flags)
          {
            position=j;
            break;
          }
        }
        *(deletion+position)=1;
      }
    }
  }
  int mycount=0;
  printf("###\n");
  for(int i=0;i<count;i++)
  {
    if(*(deletion+i))
    {
      struct ext2_dir_entry entry;
      entry.inode=*(realnumbers+i);
      entry.name_len=6;
      entry.file_type=EXT2_FT_REG_FILE;
      entry.name[0]='f';
      entry.name[1]='i';
      entry.name[2]='l';
      entry.name[3]='e';
      if(i+1<10)
      {
        entry.name[4]='0';
        sprintf(entry.name+5,"%d",i+1);
      }
      else
      {
        sprintf(entry.name+4,"%d",(i+1)/10);
        sprintf(entry.name+5,"%d",(i+1)%10);
      }
      printf("%s\n",entry.name);
      struct ext2_inode lostandfound;
      lseek(fd,BLOCK_OFFSET(group.bg_inode_table)+sizeof(struct ext2_inode)*(entry.inode-1),SEEK_SET);
      read(fd,&lostandfound,sizeof(struct ext2_inode));
      //lostandfound.i_mode=EXT2_S_IFREG | EXT2_S_IRUSR;
      lostandfound.i_flags=0;
      lostandfound.i_dtime=0;
      lseek(fd,BLOCK_OFFSET(group.bg_inode_table)+sizeof(struct ext2_inode)*(entry.inode-1),SEEK_SET);
      write(fd,&lostandfound,sizeof(struct ext2_inode));
      lseek(fd,BLOCK_OFFSET(group.bg_inode_table)+sizeof(struct ext2_inode)*10,SEEK_SET);
      read(fd,&lostandfound,sizeof(struct ext2_inode));
      if(mycount<(block_size-24)/16)
      {
        entry.rec_len=block_size-24-16*mycount;
        if(mycount==0)
        {
          int pointer;
          pointer=12;
          lseek(fd,BLOCK_OFFSET(lostandfound.i_block[0])+12+4,SEEK_SET);
          write(fd,&pointer,2);
          lseek(fd,BLOCK_OFFSET(lostandfound.i_block[0])+24,SEEK_SET);
          write(fd,&entry,16);
        }
        else
        {
          int pointer;
          pointer=16;
          lseek(fd,BLOCK_OFFSET(lostandfound.i_block[0])+24+16*(mycount-1)+4,SEEK_SET);
          write(fd,&pointer,2);
          lseek(fd,BLOCK_OFFSET(lostandfound.i_block[0])+24+16*mycount,SEEK_SET);
          write(fd,&entry,16);
        }
      }
      else
      {
        entry.rec_len=block_size-16*(mycount-(block_size-24)/16);
        if(mycount==(block_size-24)/16)
        {
          lseek(fd,BLOCK_OFFSET(lostandfound.i_block[1]),SEEK_SET);
          write(fd,&entry,16);
        }
        else
        {
          int pointer;
          pointer=16;
          lseek(fd,BLOCK_OFFSET(lostandfound.i_block[1])+16*(mycount-(block_size-24)/16-1)+4,SEEK_SET);
          write(fd,&pointer,2);
          lseek(fd,BLOCK_OFFSET(lostandfound.i_block[1])+16*(mycount-(block_size-24)/16),SEEK_SET);
          write(fd,&entry,16);
        }
      }
      mycount++;
    }
  }
  close(fd);
  return 0;
}
