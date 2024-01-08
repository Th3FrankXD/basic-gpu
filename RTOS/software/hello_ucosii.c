#include <stdio.h>
#include "includes.h"
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdbool.h>
#include <sys/alt_irq.h>

#define   TASK_STACKSIZE       2048
OS_STK    count_stk[TASK_STACKSIZE];
OS_STK    render_stk[TASK_STACKSIZE];

#define gpu (volatile uint32_t*) 0x00020008
#define sevensegment (volatile uint32_t*) 0x00020000
#define NUM 25

struct Square {
	char R;
	char G;
	char B;
	char size;
	int posX;
	int posY;
	int speedX;
	int speedY;
};

void ClearScreen(int R, int G, int B) {
	uint color = B;
	color = color << 4;
	color = color | G;
	color = color << 4;
	color = color | R;
	color = color << 20;
	*(gpu) = color;
}

// 240x320
// 4,	4,	4,	3,		9,	8
// R,	G,	B,	Size	X,	Y
void RenderSquare(struct Square square) {
	uint command = square.B;
	command = command << 4;
	command = command | square.G;
	command = command << 4;
	command = command | square.R;
	command = command << 3;
	command = command | square.size;
	command = command << 9;
	command = command | square.posX;
	command = command << 8;
	command = command | square.posY;

	*(gpu) = command;
}

bool done = false;

void irq_vsync() {
	if (done == true) {
		ClearScreen(15, 15, 15);
		done = false;
	}
}

#define COUNT_PRIORITY      1
#define RENDER_PRIORITY      2

void Count(void* pdata)
{
  uint32_t counter = 0;
  while (1)
  { 
	*sevensegment = counter;
	counter++;
    OSTimeDlyHMSM(0, 0, 1, 0);
  }
}
void Render(void* pdata)
{
    int squares = 0;
    int counter = 0;

    struct Square list[NUM];

    for (int i=0; i < NUM; i++) {
    	struct Square test;
    	test.R = rand() % (15 + 1 - 0) + 0;
    	test.G = rand() % (15 + 1 - 0) + 0;
    	test.B = rand() % (15 + 1 - 0) + 0;
    	test.size = rand() % (7 + 1 - 1) + 1;
    	test.posX = rand() % (250 + 1 - 50) + 50;
    	test.posY = rand() % (200 + 1 - 50) + 50;
    	test.speedX = rand() % (5 + 1 - 1) + 1;
    	test.speedY = rand() % (5 + 1 - 1) + 1;
    	list[i] = test;
    }

	while(1){
		if (done == false) {
		    for (int i=0; i < squares; i++) {
		    	if (list[i].posX > 320 - list[i].size*2 - 2 || list[i].posX < 0 + list[i].size*2 + 2) {
		    		list[i].speedX = list[i].speedX * -1;
		    	}
		    	if (list[i].posY > 240 - list[i].size*2 - 2 || list[i].posY < 0 + list[i].size*2 + 2) {
					list[i].speedY = list[i].speedY * -1;
				}
		    	list[i].posX += list[i].speedX;
				list[i].posY += list[i].speedY;
		    	RenderSquare(list[i]);
		    }
		    counter += 1;
		    if (counter > 25) {
		    	if (squares < NUM) {
		    		squares += 1;
		    	}
		    	counter = 0;
		    }
			done = true;
		}
	};
}

int main(void)
{
  alt_ic_isr_register(0, 1, irq_vsync, 0, 0);
  alt_ic_irq_enable(0, 1);

  OSTaskCreateExt(Count,
                  NULL,
                  (void *)&count_stk[TASK_STACKSIZE-1],
                  COUNT_PRIORITY,
                  COUNT_PRIORITY,
                  count_stk,
                  TASK_STACKSIZE,
                  NULL,
                  0);
              
               
  OSTaskCreateExt(Render,
                  NULL,
                  (void *)&render_stk[TASK_STACKSIZE-1],
                  RENDER_PRIORITY,
                  RENDER_PRIORITY,
                  render_stk,
                  TASK_STACKSIZE,
                  NULL,
                  0);
  OSStart();
  return 0;
}
