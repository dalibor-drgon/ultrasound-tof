#include "Vatan.h"
#include <stdio.h>
#include <math.h>

Vatan ins;

void tick() {
    ins.clk = 1;
    ins.eval();
    ins.clk = 0;
    ins.eval();
}

uint32_t atanb(double log) {
    ins.log = log * (1<<16);
    tick();
    ins.log = 0;
    for(unsigned i = 0; i < 3; i++)
        tick();
    return ins.out;
}

void test(double log) {
    uint32_t got = atanb(log);
    uint32_t exp = (atan(pow(2, log)) - 0.25 * M_PI) / (0.25 * M_PI) * (1<<20);
    printf("AtanLog(%8f) = %8x vs exp %8x\n", log, got, exp);
}

int main() {
    tick();

    test(1.1985);
}
