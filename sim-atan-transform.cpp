#include "Vatan_transform.h"

Vatan_transform ins;

void tick() {
    ins.clk = 1;
    ins.eval();
    ins.clk = 0;
    ins.eval();
}

uint32_t atan2b(int32_t sin, int32_t cos) {
    ins.cos_sum = cos;
    ins.sin_sum = sin;
    tick();
    ins.cos_sum = 0;
    ins.sin_sum = 0;
    for(unsigned i = 0; i < 13; i++) 
        tick();
    return ins.offset;
}

#include <vector>
#include <utility>

std::vector<std::pair<int64_t, int64_t>> err;

unsigned largest_error = 0;
unsigned errors = 0;
unsigned test(int64_t sin, int64_t cos) {
    int32_t exp = (uint32_t) round((atan2(sin, cos) - 0 * M_PI) / M_PI * (1 << 15)) & 0xffff;
    int32_t got = atan2b(sin, cos);
    printf("Atan(%8x, %8x) = %8x vs expected %8x [Debug %8x]\n", sin, cos, got, exp, ins.debug);
    unsigned error = abs(((int32_t) (exp - got) << 16) >> 16);
    if(error > largest_error)
        largest_error = error;
    if(error > 5) {
        printf("ERROR!\n");
        err.push_back(std::make_pair<int64_t, int64_t>(std::move(sin), std::move(cos)));
        errors++;
    }
}


int main() {
    tick();

    test(2, 0);
    test(-2, 0);

    test(0, 2);
    test(0, -2);

    test(2, 1);
    test(2, -1);
    test(-2, 1);
    test(-2, -1);

    if(1)
    return 0;

    test(1, 2);
    test(1, -2);
    test(-1, 2);
    test(-1, -2);

    test(7, 2);
    test(7, -2);
    test(-7, 2);
    test(-7, -2);

    test(2, 7);
    test(2, -7);
    test(-2, 7);
    test(-2, -7);

    if(0)
    for(unsigned i = 0; i < 100*4000; i++) {
        int y = (rand() << 2) + (rand() & 3);
        int x = (rand() << 2) + (rand() & 3);
        test(y, x);
    }

    printf("%u Errors, largest %u\n", errors, largest_error);
    for(auto & pair : err) {
        printf(" - %ld %ld\n", pair.first, pair.second);
    }

}
