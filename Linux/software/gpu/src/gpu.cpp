#include <gpu.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdio.h>

volatile bool vsync = false;

static void SigHandler(int sig){
    vsync = true;
}

GPU::GPU(){
    int32_t number;
    struct sigaction action;

    sigemptyset(&action.sa_mask);
    action.sa_flags = (SA_RESTART);
    action.sa_handler = SigHandler;
    sigaction(42, &action, NULL);

    dev = open("/dev/gpu", O_WRONLY);
    if(dev < 0) {
        printf("Cannot open device file...\n");
    }

    ioctl(dev, _IO('a','a'), (int32_t*) &number);
}

GPU::~GPU(){
    close(dev);
}

int GPU::ClearScreen(uint8_t R, uint8_t G, uint8_t B){
	uint32_t color = B;
	color = color << 4;
	color = color | G;
	color = color << 4;
	color = color | R;
	color = color << 20;

    renderQueue.push_back(color);
    return 0;
}

int GPU::AddToRenderQueue(Square square){
    uint32_t command = square.B;
	command = command << 4;
	command = command | square.G;
	command = command << 4;
	command = command | square.R;
	command = command << 3;
	command = command | square.size;
	command = command << 9;
	command = command | (unsigned int)square.posX;
	command = command << 8;
	command = command | (unsigned int)square.posY;

    renderQueue.push_back(command);
    return 0;
}

int GPU::Draw(){
    while(!vsync);
    vsync = false;
    write(dev, (char*)&renderQueue[0], renderQueue.size() * 4);
    renderQueue.clear();
    return 0;
}