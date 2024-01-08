#include <gpu.h>
#include <stdio.h>
#include <stdlib.h>
#include <chrono>

float RandF(float min, float max) {
	return min + ((float)rand()/(float)(RAND_MAX/(max - min)));
}

#define NUM_SQUARES 250
std::vector<Square> entities;

int main() {
    auto currentTime = std::chrono::high_resolution_clock::now();
    auto previousTime = currentTime;
    double deltaTime = 0;

    GPU gpu;

    for (int i = 0; i < NUM_SQUARES; i++) {
    	Square square;
    	square.R = rand() % (15 + 1 - 0) + 0;
    	square.G = rand() % (15 + 1 - 0) + 0;
    	square.B = rand() % (15 + 1 - 0) + 0;
    	square.size = rand() % (7 + 1 - 1) + 1;
    	square.posX = RandF(50.0, 250.0);
    	square.posY = RandF(50.0, 200.0);
    	square.speedX = RandF(0.0, 100);
    	square.speedY = RandF(0.0, 100);
    	entities.push_back(square);
    }

    while(true) {
        previousTime = currentTime;
        currentTime = std::chrono::high_resolution_clock::now();
        deltaTime = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - previousTime).count()/1000.0;
        
        gpu.ClearScreen(15, 15, 15);
    
        for(Square &square : entities) {
            if (square.posX > 320 - square.size*2 - 2 || square.posX < 0 + square.size*2 + 2) {
                square.speedX = square.speedX * -1;
            }
            if (square.posY > 240 - square.size*2 - 2 || square.posY < 0 + square.size*2 + 2) {
                square.speedY = square.speedY * -1;
            }
            square.posX += (square.speedX * deltaTime);
            square.posY += (square.speedY * deltaTime);

            gpu.AddToRenderQueue(square);
        }

        gpu.Draw();
    }
    return 0;
}