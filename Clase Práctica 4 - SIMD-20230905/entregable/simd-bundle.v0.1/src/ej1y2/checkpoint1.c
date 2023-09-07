#include "checkpoints.h"

void invertirBytes_c(uint64_t* p){
    uint64_t p0 = p[0];
	p[0] = p[1];
    p[1] = p0;
}

