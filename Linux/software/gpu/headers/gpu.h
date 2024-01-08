#pragma once

#include <stdint.h>
#include <vector>

struct Square {
	char R;
	char G;
	char B;
	char size;
	float posX;
	float posY;
	float speedX;
	float speedY;
};

class GPU {
public:
    GPU();
    ~GPU();
    int ClearScreen(uint8_t R, uint8_t G, uint8_t B);
    int AddToRenderQueue(Square square);
    int Draw();

private:
    int dev;
    std::vector<uint32_t> renderQueue;
};