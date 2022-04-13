#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#ifndef SIZE
#define SIZE (20e6/40e3)
#endif

uint64_t tofixed(double v) {
#ifdef DAC_SINE
    return round(v * 127 + 128);
#else
    v *= (1LL << 46);
    return round(v);
#endif
}

void gen(const char *file, double (*func)(double val)) {
    int fd = open(file, O_CREAT | O_WRONLY, S_IRWXU | S_IRWXG | S_IRWXO);
    if(fd == -1) {
        perror("open");
        exit(1);
    }
    printf("%s = {", file);
    for(double i = 0; i < SIZE; i++) {
        double ang = 2 * M_PI * i / SIZE;
        uint64_t val = tofixed(func(ang));
#ifdef DAC_SINE
        if(dprintf(fd, "%02llX\n", val & 0xff) == -1) {
            perror("write");
            exit(1);
        }
        printf("\n\t8'h%02llX", val & 0xff);
#else
        if(dprintf(fd, "%012llX\n", val) == -1) {
            perror("write");
            exit(1);
        }
        printf("\n\t32'h%012llX", val);
#endif
        if(i != SIZE-1) {
            printf(", ");
        }
    }
    printf("\n}\n\n");
    close(fd);
}

int main() {
    char name[32];
#ifdef DAC_SINE
    snprintf(name, sizeof(name), "sin_dac%d.hex", (int) SIZE);
    gen(name, sin);
#elif defined(A)
#else
    snprintf(name, sizeof(name), "sin%d.hex", (int) SIZE);
    gen(name, sin);

    snprintf(name, sizeof(name), "cos%d.hex", (int) SIZE);
    gen(name, cos);
#endif

    return 0;
}
