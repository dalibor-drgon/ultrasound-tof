#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <Vlog2.h>

Vlog2 log2_ent;

void tick() {
    log2_ent.clk = 1;
    log2_ent.eval();
    log2_ent.clk = 0;
    log2_ent.eval();
}

uint32_t eval(uint32_t in) {
    log2_ent.in = in;
    for(unsigned i = 0; i < 6; i++) tick();
    return log2_ent.out;
}

double test(uint32_t in) {
    double got = eval(in) / (double) (1 << 16);
    double exp = log2(in);
    printf("Test [%u] = %f vs exp %f [debug %x]\n", in, got, exp, log2_ent.debug);
    return abs(got - exp) / 18;
}

int main() {
    test(1);
    test(2);
    test(3);
    
    double max_err = 0;
    for(unsigned i = 0; i < 20000; i++) {
        uint32_t random = rand() & ((1<<18)-1);
        if(random == 0) continue;
        double err = test(random);
        if(err > max_err) max_err = err;
    }
    printf("Max error: %g\n", max_err);
}