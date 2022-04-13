#include <Vft.h>
#include <iostream>
#include <cstdint>
#include <cmath>

Vft ft;
#define SIZE 500

void tick() {
    ft.clk = 1;
    ft.eval();
    ft.clk = 0;
    ft.eval();
}

void print_out() {
    int64_t cos = ft.cos_sum; //((int64_t) ft.cos_sum << 10) >> 10;
    int64_t sin = ft.sin_sum; //((int64_t) ft.sin_sum << 10) >> 10;
    double dcos = cos;
    double dsin = sin;
    double offset = -atan2(dsin, dcos) + (ft.offset * 2 * M_PI / SIZE);
    if(offset < 0) offset += 2 * M_PI;
    printf("%lld [0x%llx] - %lld [0x%llx] - offset %u [%.10g]\n", cos, cos, sin, sin, ft.offset, offset);
}

int main() {
    ft.rst = 1;
    tick();
    ft.rst = 0;
    int latency = 3;
    
    for(unsigned i = 0; i < SIZE+latency; i++) {
        ft.data = round((1<<10) * cos(2 * M_PI * i / SIZE + 0.5));
        tick();
    }
    
    /*ft.data = 0;
    for(unsigned i = 0; i < latency; i++) {
        tick();
    }
    */

    print_out();

    for(unsigned i = 0; i < SIZE+latency; i++) {
        ft.data = round((1<<10) * cos(2 * M_PI * i / SIZE + 0.3));
        tick();
    }

    ft.data = 0;
    /*for(unsigned i = 0; i < latency; i++) {
        tick();
    }*/

    print_out();

    for(unsigned i = 0; i < 139; i++) {
        tick();
    }

    for(unsigned i = 0; i < SIZE+latency; i++) {
        ft.data = round((1<<10) * cos(2 * M_PI * i / SIZE + 2.3));
        tick();
    }

    ft.data = 0;
    /*
    for(unsigned i = 0; i < latency; i++) {
        tick();
    }*/

    print_out();

    for(unsigned i = 0; i < SIZE+latency; i++) {
        tick();
    }

    print_out();

    return 0;
}
